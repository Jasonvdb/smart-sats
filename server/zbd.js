const ZBD_API = process.env.ZBD_API;
if (!ZBD_API) {
    console.error('ZBD_API environment variable is not set');
    process.exit(1);
}

const PUSH_SERVER = process.env.PUSH_SERVER;
if (!PUSH_SERVER) {
    console.error('PUSH_SERVER environment variable is not set');
    process.exit(1);
}

async function checkPaid(chargeId) {
      const config = {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'apikey': ZBD_API
        }
      };
    
      try {
        const response = await fetch('https://api.zebedee.io/v0/charges/' + chargeId, config);
        const {data} = await response.json();

        return !!data.confirmedAt;
      } catch (error) {
        // Handle error
        console.error(error);
        return false;
      }
}

async function chargeUser(sats, description) {
    const timeout = 30;

    const data = JSON.stringify({
        "amount": sats * 1000,
        "description": description,
        "expiresIn": timeout,
        "internalId": "12345678",
        "callbackUrl": "https://my-website.com/zbd-callback"
    });

    const config = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'apikey': ZBD_API
        },
        body: data
    };

    try {
        const response = await fetch('https://api.zebedee.io/v0/charges', config);

        const {data} = await response.json();        

        const { id, invoice } = data;

        fetch(PUSH_SERVER + '/charge?bolt11=' + invoice.request, {
            headers: { Authorization: "Bearer " + "TODO" },
            method: "POST",
            body: JSON.stringify({}), //TODO add to body rather than query
        }).catch((error) => {
            throw new Error("Error sending push notification request");
        });

        let isPaid = false;

        for (let i = 0; i < timeout; i++) {
            isPaid = await checkPaid(id);

            if (isPaid) {
                break;
            }

            await new Promise((resolve) => setTimeout(resolve, 1000));
        }

        return isPaid;
    } catch (error) {
        console.error("Charge failed :( " + error);
        throw error;
    }
}

exports.chargeUser = chargeUser;