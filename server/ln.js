const lnService = require('ln-service');
const {once} = require('events');

const LND_MACAROON = process.env.LND_MACAROON;
if (!LND_MACAROON) {
    console.error('LND_MACAROON environment variable is not set');
    process.exit(1);
}

const LND_SOCKET = process.env.LND_SOCKET;
if (!LND_SOCKET) {
    console.error('LND_SOCKET environment variable is not set');
    process.exit(1);
}

const {lnd} = lnService.authenticatedLndGrpc({
    macaroon: LND_MACAROON,
    socket: LND_SOCKET,
});

lnService.getWalletInfo({lnd}, (err, result) => {
    if (err) { 
        console.log(err);
    }

    const {public_key, version, pending_channels_count, active_channels_count, peers_count} = result;
    console.log({public_key, version, pending_channels_count, active_channels_count, peers_count});
});

const peers = [
    {
        //Breez lsp:
        public_key: '02c811e575be2df47d8b48dab3d3f1c9b0f6e16d0d40b5ed78253308fc2bd7170d',
        socket: '212.129.58.219:9835'
    },
    {
        //Voltage:
        public_key: '02cfdc6b60e5931d174a342b20b50d6a2a17c6e4ef8e077ea54069a3541ad50eb0',
        socket: '52.89.237.109:9735'
    }
];

peers.forEach((peer) => {
    const {public_key, socket} = peer;

    lnService.addPeer({lnd, socket, public_key}, (err, result) => {
        if (err) {
            console.log(err);
        }

        console.log("Peer added");
    });
});

lnService.getChannelBalance({lnd}, (err, result) => {
    if (err) {
        console.log(err);
    }

    console.log(result);
});

lnService.getChannels({lnd}, (err, result) => {
    if (err) {
        console.log(err);
    }

    result.channels.forEach(({is_active, capacity}) => {
        console.log("Channel:");
        console.log({is_active, capacity});
    });
});

async function chargeUser(amount) {
    const timeout = 5;
    //Convert to async await
    const result = await new Promise((resolve, reject) => {
        lnService.createInvoice({
            lnd,
            tokens: amount,
            description: 'testeeee',
            is_including_private_channels: true,
            expires_at: new Date(Date.now() + 60 * 60 * 1000).toISOString()
        }, (err, result) => {
            if (err) {
            reject(err);
        } else {
            resolve(result);
        }});
    });

    const { id, request: bolt11 } = result;

    let paid = false;
    //TODO check if payment was made
    const sub = lnService.subscribeToInvoice({id, lnd}).addListener('invoice_updated', async (invoice) => {
        const {received} = invoice;
        if (received == amount) {
            paid = true;
            console.log("INVOICE PAID");
            sub.removeAllListeners();
            return;
        }
    });

    //TODO send to user
    console.log("TODO pay this:");
    console.log(bolt11);
        
    for (let i = 0; i < timeout; i++) {
        if (paid) {
            break;
        }

        await new Promise((resolve) => setTimeout(resolve, 1000));
    }

    return paid;
}

exports.chargeUser = chargeUser;