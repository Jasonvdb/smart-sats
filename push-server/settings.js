require('dotenv').config();

const HOST = process.env.HOST;
if (!HOST) {
    console.error('HOST environment variable is not set');
    process.exit(1);
}

const PORT = process.env.PORT;
if (!PORT) {
    console.error('PORT environment variable is not set');
    process.exit(1);
}

const pushSettings = {
    apn: {
        token: {
            key: './certs/AuthKey_X8AALL8SCD.p8', // optionally: fs.readFileSync('./certs/key.p8')
            keyId: 'X8AALL8SCD',
            teamId: 'BJJ5WGNUJH',
        },
        production: false // true for APN production environment, false for APN sandbox environment,
    },
    isAlwaysUseFCM: false, // true all messages will be sent through node-gcm (which actually uses FCM)
};

const defaultPaymentAlert = {
    title: 'Incoming charge',
    body: 'Please open app and ask agent to try again.'
}

const appBundleID = 'jasonvdb.SmartSats';

module.exports = {host: HOST, port: PORT, pushSettings, defaultPaymentAlert, appBundleID};