const PushNotifications = require('node-pushnotifications');
const http = require("http");
const url = require('url');

const { pushSettings, host, port } = require('./settings');
const { fancyGuid, createPushData } = require('./helpers');

const push = new PushNotifications(pushSettings);
const fancyDb = {}; //TODO persist

// const hardcodedpushtoken = "a3ccdae5ca36db02ea0fe779a3226dc614b35a3f088290ef3d00d8fadd2062eb";

// let charge = {
//     sats: 123, //Sats sent through because we can't decode invoices yet
//     bolt11: 'lnbc240n1pj2a9cjpp54452tkya5efclsy3809rd6etxy7kzaqfr2jz00jkvz8ujf59e84sdqdw3jhxar9v4jk2cqzzsxqrrsssp5x3cp8hcwupvds6h6m9y5hje9qv45wfkhlya7ry343vt359jwsjfq9qyyssqw23u6c2devc3y22mh7t5kdv3gjlxmnv79krhwhnfcgemxr2wtxmk9p82hq6xkx637fuqkgcsn4qwyh5fhugrssz4md09vpck3qv8rlcqqtrtxs',
//     auth: 'auth123'
// };
// push.send(hardcodedpushtoken, createPushData(charge))
// .then(res => {
//     console.log("Sent");
//     console.log(JSON.stringify(res));
//     process.exit(0);
// })
// .catch((error) => {
//     console.error(error);
//     console.log(JSON.stringify(error));
// });
// return;

const requestListener = (req, res) => {
    res.setHeader('Content-Type', 'application/json');

    console.log('Request...');
    const parts = url.parse(req.url, true);
    const query = parts.query;

    //TODO allow registering per agent
    if (parts.pathname === "/register" && query.token) {
        const id = fancyGuid();

        console.log("Registering agent token :" + id);
        fancyDb[id] = query.token;

        res.writeHead(200);
        const result = JSON.stringify({id, hook: `${host}/charge?token=${id}`})
        console.log(result);
        res.end(result);
        return;
    }

    if (parts.pathname === "/revoke" && query.id) {
        console.log("Revoking agent: " + query.id);

        delete fancyDb[query.id];

        res.writeHead(200);
        res.end(JSON.stringify({result: 'revoked'}));
        return;
    }

    //Called by agent
    if (parts.pathname === "/charge" && query.token) {
        const {bolt11} = query;
        let deviceToken = fancyDb[query.token];
        if (!deviceToken) {
            console.log('token not found in DB' + query.token);
            res.writeHead(404);
            res.end(JSON.stringify({error: 'invalid token or token revoked'}));
            return;
        }

        let charge = {
            bolt11,
            auth: query.token // App needs to validate agent token
        };

        const data = createPushData(charge);

        push.send(deviceToken, data)
            .then((results) => {
                if (results[0].success) {
                    console.log('SENT!');
                    res.writeHead(200);
                    res.end(JSON.stringify({result: 'notified'}));
                    return;
                }

                res.writeHead(500);
                res.end(JSON.stringify({error: 'failed to notify'}));

            })
            .catch((err) => {
                res.writeHead(500);
                console.error(err);
                res.end(JSON.stringify({error: err}));
            });

        return;
    }

    if (parts.pathname === "/info") {
        res.writeHead(200);
        const result = JSON.stringify({hook: `${host}/charge?token=123`})
        console.log(result);
        res.end(result);
        return;
    }

    res.writeHead(404);
    res.end("404 - Not found");
};

const server = http.createServer(requestListener);
server.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
