const PushNotifications = require('node-pushnotifications');
const http = require("http");
const url = require('url');

const { pushSettings, host, port } = require('./settings');
const { fancyGuid, createPushData } = require('./helpers');

const push = new PushNotifications(pushSettings);
const fancyDb = {}; //TODO persist

let charge = {
    sats: 123, //Sats sent through because we can't decode invoices yet
    bolt11: 'lnbc1240n1pj2un9fpp56afscja0q395gk60r96wucl7upqkyh3qzfupdw774j9zhedjyh4sdqdw3jhxar9v4jk2cqzzsxqrrsssp55kahls20rk05cj0r5ltur2ud63290djvn87wf4vwzv78n6c89w6q9qyyssqmscu4u39lmypsq4ffxeadvzhfa8r6k5nylsp8chn6lsfw9mcmdlqw8r65nwrxjn7k8tgkra6acv5c8ecse2as6ra8gcv9k6pagdwt8sq22atwz',
    auth: 'auth123'
};
push.send("9d337e92ce0c5b86915bd3cca5218e9f988268a4a74be6b279b09e95a8fcf66b", createPushData(charge))
.then(res => {
    console.log("Sent");
    console.log(JSON.stringify(res));
    process.exit(0);
})
.catch((error) => {
    cno
    console.error(error);
    console.log(JSON.stringify(error));
});
return;

const requestListener = (req, res) => {
    res.setHeader('Content-Type', 'application/json');

    console.log('Request...');
    const parts = url.parse(req.url, true);
    const query = parts.query;

    //TODO allow registering per agent
    if (parts.pathname == "/register" && query.token) {
        const guid = fancyGuid();

        //TODO validate token
        fancyDb[guid] = query.token;

        res.writeHead(200);
        res.end(JSON.stringify({result: `http://${host}:${port}/${guid}`}));
        return;
    }

    if (parts.pathname == "/revoke") {
        //TODO
    }

    //Called by agent
    if (parts.pathname == "/charge") {
        const {amount, guid} = query;
        let deviceToken = fancyDb[guid];
        if (!deviceToken) {
            console.log('guid not found in DB');
            res.writeHead(404);
            res.end(JSON.stringify({error: 'invalid token'}));
            return;
        }

        const data = createPushData({
            amount,
            guid
        });

        push.send(deviceToken, data)
            .then((results) => { 
                delete fancyDb[guid];

                if (results[0].success) {
                    console.log('SENT!');
                    res.writeHead(200);
                    res.end(JSON.stringify({result: 'notified', delay: 15000}));
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
};

const server = http.createServer(requestListener);
server.listen(port, host, () => {
    console.log(`Server is running on http://${host}:${port}`);
});