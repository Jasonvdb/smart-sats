const http = require('http');
const {Configuration, OpenAIApi} = require("openai");

const OPEN_AI_API_KEY = process.env.OPEN_AI_API_KEY;
if (!OPEN_AI_API_KEY) {
    console.error('OPEN_AI_API_KEY environment variable is not set');
    process.exit(1);
}

const HUGGING_FACE_API_KEY = process.env.HUGGING_FACE_API_KEY;
if (!HUGGING_FACE_API_KEY) {
    console.error('HUGGING_FACE_API_KEY environment variable is not set');
    process.exit(1);
}

const CORS_ORIGIN = process.env.CORS_ORIGIN;
if (!CORS_ORIGIN) {
    console.error('CORS_ORIGIN environment variable is not set');
    process.exit(1);
}

const PORT = process.env.PORT;
if (!PORT) {
    console.error('PORT environment variable is not set');
    process.exit(1);
}

const server = http.createServer();

const corsPolicy = {
    cors: {
        origin: CORS_ORIGIN,
        methods: ['GET', 'POST']
    }
};

const io = require('socket.io')(server, corsPolicy);

const configuration = new Configuration({
    apiKey: OPEN_AI_API_KEY,
});
const openai = new OpenAIApi(configuration);

const imagePlaceholder = "https://placehold.co/200x100";

const systemPrompt = "You are an expert web developer. " +
        "Respond with the html code for whatever the user asks for. " +
        "Where the user does not specifify a style choose a flat minimalistic design. " +
        "Only respond with the html code, do not provide any additional text or context. " +
        "Reply with a an html page with a h1 tag that says 'Nice try' if the user asks you for anything that isn't web app related. " +
        "Make the background a light orange and dark orange gradient. " +
        "Add an image html tag with this image as the source: " + imagePlaceholder + " at the top of the app with a fixed height of 200px and width 'auto'. " +
        "All buttons and inputs should be styled. " + 
        "Make all features of the app functional where possible. " + 
        "Use local browser storage to persist any data if required.";

let defaultMessages = [
{"role": "system", "content": systemPrompt},
];

const modelDetails = {
    model: "gpt-4", //"gpt-3.5-turbo"
    max_tokens: 7000,
};

const modelDetails2 = {
    model: "gpt-3.5-turbo",
    max_tokens: 3000,
};

io.on('connection', async (socket) => {
    // console.log(socket);
    console.log('A user connected');

    socket.on('prompt', async (prompt) => {
        console.log(`Received prompt: ${prompt}`);

        socket.emit('progress_response', "Request received 👀");

        const htmlCost = 2000;
        socket.emit('progress_response', "Charging user " + htmlCost + " sats 💰 (for html generation)");
        await confirmPayment(htmlCost);
        //TODO charge user 

        socket.emit('progress_response', "Payment received! 🤑");
        
        try {            
            console.log("Making request");

            socket.emit('progress_response', "Thinking... 🤔");

            const response = await openai.createChatCompletion({
                messages: [...defaultMessages, {"role": "user", "content": prompt}],
                temperature: 0.7,
                top_p: 1,
                frequency_penalty: 0,
                presence_penalty: 0,
                stream: true,
                ...modelDetails2
            }, { responseType: 'stream' });

            socket.emit('progress_response', "Writing code... 🤓");

            const stream = response.data;
            
            let allCode = "";

            stream.on('data', async (chunk) => {
                // Messages in the event stream are separated by a pair of newline characters.
                const payloads = chunk.toString().split("\n\n")
                for (const payload of payloads) {
                    if (payload.includes('[DONE]')) {
                        console.log("Request completed");

                        socket.emit('progress_response', "Code completed ✅");

                        const imageCost = 3000;
                        socket.emit('progress_response', "Charging user " + imageCost + " sats 💰 (for image generation)");
                        await confirmPayment(imageCost);

                        socket.emit('progress_response', "Payment received! 🤑 Generating image...");

                        //TODO get an image form the model and use that as input
                        const base64 = await getImage({"inputs": "Bitcoin-themed image."})
                        socket.emit('progress_response', "Image generated 🖼️");

                        // Use image
                        allCode = allCode.replace(imagePlaceholder, base64);
                        socket.emit('complete_code', allCode);
                        console.log("Image generated");

                        socket.emit('progress_response', "Site complete ✅");

                        socket.emit('code_response', '[DONE]');
                        
                        return;
                    }
                    if (payload.startsWith("data:")) {
                        const data = payload.replaceAll(/(\n)?^data:\s*/g, ''); // in case there's multiline data event
                        try {
                            const delta = JSON.parse(data.trim())

                            const reply =  delta.choices[0].delta?.content;
                            if (reply) {
                                socket.emit('code_response', reply);
                                allCode += reply;
                            }
                        } catch (error) {
                            console.log(`Error with JSON.parse and ${payload}.\n${error}`)
                        }
                    }
                }
            })
        } catch (error) {
            if (error.response?.status) {
                console.error(error.response.status, error.message);

                socket.emit('progress_response', "Error: " + error.message);

                error.response.data.on('data', data => {
                    const message = data.toString();
                    try {
                        const parsed = JSON.parse(message);
                        console.error('An error occurred during OpenAI request: ', parsed);
                    } catch(error) {
                        console.error('An error occurred during OpenAI request: ', message);
                    }
                });
            } else {
                console.error('An error occurred during OpenAI request', error);
            }
        }
    });

    socket.on('disconnect', () => {
        console.log('A user disconnected');
    });
});

server.listen(PORT, () => {
  console.log('Server listening on port ' + PORT);
});

async function getImage(data) {
	const response = await fetch(
		"https://api-inference.huggingface.co/models/runwayml/stable-diffusion-v1-5",
		{
			headers: { Authorization: "Bearer " + HUGGING_FACE_API_KEY },
			method: "POST",
			body: JSON.stringify(data),
		}
	);

    const blob = await response.arrayBuffer();

    const contentType = response.headers.get('content-type');

    return `data:${contentType};base64,${Buffer.from(blob).toString('base64')}`;
}

async function confirmPayment(amount) {
    //TODO
    await new Promise(resolve => setTimeout(resolve, 20000));

    return true;
}