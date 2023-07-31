const { pushSettings, defaultPaymentAlert, appBundleID, host, port, electrumConfig } = require('./settings');

const fancyGuid = () => {
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
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
        badge: 0,
        sound: 'ping.aiff',
    };
};

module.exports = {fancyGuid, createPushData};
