const fetch = require('node-fetch');

const HUGGING_FACE_API_KEY = process.env.HUGGING_FACE_API_KEY;
if (!HUGGING_FACE_API_KEY) {
    console.error('HUGGING_FACE_API_KEY environment variable is not set');
    process.exit(1);
}

const REGISTRATION_HOST = process.env.REGISTRATION_HOST;
if (!REGISTRATION_HOST) {
    console.error('REGISTRATION_HOST environment variable is not set');
    process.exit(1);
}

const REGISTRATION_PORT = process.env.REGISTRATION_PORT;
if (!REGISTRATION_PORT) {
    console.error('REGISTRATION_PORT environment variable is not set');
    process.exit(1);
}

const getImage = async (data) => {
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

const getRandomToken = () => {
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
}

const getRegistrationQR = (token) => {
    //TODO show host for development
    return `smartsats:${REGISTRATION_HOST}/register?token=${token}`;
}

let fancyDB = {
    "token123": {
        authed: false,
        totalBudget: 100,
        spentBudget: 0,
        hook: ""
    }
};

const agentDetails = {
    id: "el-cheapo-web-dev",
    name: "Cheap Web Dev",
    description: "The cheapest web developer you will ever find. Guaranteed to get your sats worth."
};

module.exports = {getImage, getRandomToken, getRegistrationQR, fancyDB, agentDetails};
