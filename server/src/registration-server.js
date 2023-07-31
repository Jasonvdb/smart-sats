const http = require("http");
const url = require('url');
const {fancyDB, agentDetails} = require("./helpers");

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
const setupRegistrationServer = () => {
    const requestListener = (req, res) => {
        res.setHeader('Content-Type', 'application/json');

        console.log('Request...');
        const parts = url.parse(req.url, true);
        const query = parts.query;

        if (parts.pathname === "/register") {
            if (!query || !query.token || !query.hook || !query.budget) {
                res.writeHead(400);
                const result = JSON.stringify({error: "Missing token, hook or budget"});
                console.log(result);
                res.end(result);
                return
            }

            const {hook, budget} = query;

            console.log("Registering wallet: " + JSON.stringify(query));
            console.log("Budget: " + budget);

            fancyDB[query.token] = {
                authed: true,
                totalBudget: budget,
                spentBudget: 0,
                hook
            }

            res.writeHead(200);
            const result = JSON.stringify(agentDetails);
            console.log(result);
            res.end(result);
            return;
        }

        res.writeHead(404);
        res.end("404 - Not found");
    };

    const server = http.createServer(requestListener);

    server.listen(REGISTRATION_PORT, REGISTRATION_HOST.replaceAll('http://', '').replaceAll('https://', ''), () => {
        console.log(`Registration server is running on ${REGISTRATION_HOST}:${REGISTRATION_PORT}`);
    });
};

module.exports = {
    setupRegistrationServer
}
