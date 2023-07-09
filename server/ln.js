const lnService = require('ln-service');

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

// const public_key = '02c811e575be2df47d8b48dab3d3f1c9b0f6e16d0d40b5ed78253308fc2bd7170d';
// const socket = '212.129.58.219:9835';

//Breez lsp:
const public_key = '02cfdc6b60e5931d174a342b20b50d6a2a17c6e4ef8e077ea54069a3541ad50eb0';
const socket = '52.89.237.109:9735';

//Voltage 02cfdc6b60e5931d174a342b20b50d6a2a17c6e4ef8e077ea54069a3541ad50eb0@52.89.237.109:9735

lnService.addPeer({lnd, socket, public_key}, (err, result) => {
    console.log("ADD PEER");

    if (err) {
        console.log(err);
    }
    
    console.log(result);
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

    console.log(result);
});

lnService.createInvoice({
    lnd, 
    tokens: 200, 
    description: 'testeeee', 
    //Expires 1 hour from now
    expires_at : new Date(Date.now() + 60 * 60 * 1000).toISOString()
}, (err, result) => {
    if (err) { 
        console.log(err);
        return;
    }

    const {id, request} = result;
    console.log("Invoice ID " + id);
    console.log("Invoice request " + request);
});

// lnService.pay({lnd, request: 'lnbc340n1pj2sn8wdqs23jhxarfdenjq42fpp5j8laesqpxms8ltfpmwjy5d4kw3t83lwn30h6g6f08dpn8v0l55csxqyjw5qsp522fdlklssjla9jhjjwt2ayz08m2a9zk6xjajh0nyej9f0pv9kw3s9qrsgqcqpxrzjqtypret4hcklglvtfrdt85l3exc0dctdp4qttmtcy5es3lpt6uts6nd9qe53j35xd5qqqqlgqqqqqzsqygrdax0scrttctudgftjsfkwe0hmz92x7jjd0hce6aelnc2tlmg0kz5daflh3wdcfvqvwlw082jz5ee7w0mprrunqnnpjgya6e8uutjusp7xvant' }, (err, result) => {
//     if (err) { 
//         console.log(err);
//         return;
//     }

//     console.log(result);
// });