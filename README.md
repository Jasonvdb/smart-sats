# SmartSats

SmartSats, a non custodial mobile lightning wallet that allows you to conveniently allocate sats for AI agents, enabling task execution within predefined budgets, with the agent having the ability to withdraw funds as needed.

### Try it out 🔗
TestFlight: https://testflight.apple.com/join/U4Zqn7Ae

Demo Agent: https://cheap-web-dev-agent.surge.sh

### The pitch 🎤
https://www.loom.com/share/e202e4dc92af41809bcde798dede5df5?sid=e2faaad8-8857-4509-8bf0-4e62857464b8


### Problems 🚨
Using your credit card on various websites poses significant risks. Currently, you have only two options: providing your payment details to a site or prepaying and allowing the site to hold your funds in a credit balance.

Lightning payments on Bitcoin offer an obvious solution, but the user experience can be improved. Dealing with the hassle of preloading funds on multiple platforms can be challenging and opening your wallet for each agent task or a few chat messages can be time-consuming and might deter users.

Due to the AI boom, users often find themselves signing up for many agents and general AI services, making it difficult to keep track of where funds have been loaded or, worse, where credit card details have been shared.

However, there exists a third and much-improved option...

![SmartSats](https://imagedelivery.net/wyrwp3c-j0gDDUWgnE7lig/37e8d7de-5c5d-4319-1f51-7f18846a6e00/public)

### Solution 📲
A wallet that allows the user to fully control what they’re spending and where they’re spending. Users simply scan a QR or tap a link to preauthorise a budget for an agent.

All keys and funds stay fully in control of the user, while allowing the agent to easily deduct what they need and when they need it so they’re still able to operate on auto pilot without user intervention.

Any of the neat projects submitted to the hackathon could implement this to charge their users.

### Benefits ✅
Agents cannot run up billing accounts

Agents can operate autonomously without needing to wait for manual payments. Funds can be automatically deducted from the agent’s budget in the app.

Agent providers don’t need to hold user funds in credit. Not your keys, not your cheese.

Simple and easy to cut off agents, no searching through multiple logins and sites for cancel buttons. Users can cancel agents they don’t find useful, and up the budgets of ones they find have value.

![Easy budgeting for agents](https://imagedelivery.net/wyrwp3c-j0gDDUWgnE7lig/b542fc9e-e588-4811-6b6d-48e8672a3300/public)

### How does it work? 👨‍💻
User scans a QR or taps an authorisation link

Allocates a budget locally 

Requests a push notification hook from the wallets notification server. This allows whoever has this hook to wake the app up in the background when it needs to make a payment. The hook can be revoked once an agent is unlinked.

The wallet then calls a registration endpoint provided in the QR which sends the hook and the authorised amount to the agent.

The agent can create bolt11 invoices and post them to that hook as and when they need the wallet to make payments.

![Agents deducting funds without user interaction](https://imagedelivery.net/wyrwp3c-j0gDDUWgnE7lig/5f8a2771-07d2-4eb4-83a3-0911da85b600/public)

### How was it built? 🛠
Wallet uses Breez SDK (Blockstream Greenlight). By using the Breez LSP and this approach, the development time for the wallet was significantly faster. There was no need for building a lightning wallet from scratch so was able to get this up and running in less than a month part time.

Swift/SwiftUI for the wallet. Because of the need for background tasks for payments to happen asynchronously, without user interaction, the fastest way to build this was just natively and only iOS for now.

The demo web site builder agent was done pretty simply and I’ve been using that more to test and demo the wallet. Using ReactJS, NodeJS, GPT3.5 (for the HTML), Stable-Diffusion hosted on Hugging Face (for the site image), ZBD for creating charge requests.

### Next steps 🪜
If it looks like there is demand for something like this I would like to build all the agent charge logic out into a library for other agents to easily add support for these payments to their projects.

## TODO
- [x] Setup iOS app with Breez SDK
- [x] Setup basic web dev agent for demo (builds a simple website)
- [x] Web dev invoice charging
- [x] Push server Setup
- [x] Mobile payment from background
- [x] Mobile background payment logic
- [x] Setup LND node for receiving payments
- [x] Push server auth
- [x] Server budgeting logic
- [x] Mobile budgeting logic
- [x] Mobile UI
- [x] Demo UI
- [x] Deploy demo
- [x] Push app to TestFlight
- [ ] Refactor demo to use langchain
- [ ] Migrate to Replit
- [ ] Agent to use L402