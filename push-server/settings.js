const host = '192.168.0.105';
const port = 8000;

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

module.exports = {host, port, pushSettings, defaultPaymentAlert, appBundleID};