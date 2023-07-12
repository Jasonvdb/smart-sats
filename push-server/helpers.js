const Electrum = require("electrum-client");
const { pushSettings, defaultPaymentAlert, appBundleID, host, port, electrumConfig } = require('./settings');

const fancyGuid = () => {
    let firstPart = (Math.random() * 46656) | 0;
    let secondPart = (Math.random() * 46656) | 0;
    firstPart = ("000" + firstPart.toString(36)).slice(-3);
    secondPart = ("000" + secondPart.toString(36)).slice(-3);
    return firstPart + secondPart;
};

const createPushData = (payload) => {
    return {
        topic: appBundleID,
        title: defaultPaymentAlert.title,
        body: defaultPaymentAlert.body,
        alert: { // iOS only
            ...defaultPaymentAlert,
            payload
        },
        priority: 'high',
        contentAvailable: 1,
        mutableContent: 1,
        badge: 1,
        sound: 'ping.aiff',
    };
};

module.exports = {fancyGuid, createPushData};