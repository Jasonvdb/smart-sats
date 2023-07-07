//
//  ContentView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/06.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var ln = LN.shared
    @State var displayError = ""
    @State var message = ""

    var body: some View {
        VStack {
            if let info = ln.nodeInfo {
                Text("Block height: \(info.blockHeight)")
                Text("Channel balance: \(info.channelsBalanceMsat.sats)")
                Text("Onchain balance: \(info.onchainBalanceMsat.sats)")
                Text("Peers: \(info.connectedPeers.joined(separator: ", "))")
            }
            
            Text(displayError).foregroundColor(.red)
            Text(message).foregroundColor(.green)

            if !ln.hasNode {
                AsyncButton(title: "Register node") {
                    displayError = ""
                    do {
                        try await ln.register()
                        try await ln.start()
                        message = "Node registered"
                    } catch  {
                        displayError = error.localizedDescription
                    }
                }
                
                AsyncButton(title: "Recover node") {
                    displayError = ""
                    do {
                        try await ln.recover()
                        try await ln.start()
                        message = "Node recovered"
                    } catch  {
                        displayError = error.localizedDescription
                    }
                }
            }
            
            AsyncButton(title: "LSP") {
                displayError = ""
                do {
                    if let res = try await ln.lsp() {
                        message = "\(res.pubkey)@\(res.host)"
                    }
                } catch  {
                    displayError = error.localizedDescription
                }
            }
            
            AsyncButton(title: "Recieve") {
                displayError = ""
                do {
                    let res = try await ln.receive(amountSats: UInt64((arc4random_uniform(31)) + 20), description: "Testing UI")
                    message = res.bolt11
                } catch  {
                    displayError = error.localizedDescription
                }
            }
            
            AsyncButton(title: "Pay") {
                displayError = ""
                do {
                    let inv = "lnbc1pj2sekepp5sq46emget8lpxqmqww2p9439eev9zqr9t8jzp54vm4x4xmuahuvsdqdw3jhxar9v4jk2cqzzsxqrrsssp5hg38frv6s0kpk4895s67cycvs97jm89t8ahp8tlsmlxguwvqajcs9qyyssq46zgllq3kfcvdexz7dpyaycxedx0td7j9dz243s0exm53djywykr50t3vz36qx0r0y4a7qrws339ycj5qr6m9ruwjc7w7xeq8qym58spde4cad"
                    let res = try await ln.pay(inv, amountSats: 100)
                    message = "Paid!"
                } catch  {
                    displayError = error.localizedDescription
                }
            }
        }
        .padding()
        
        List(ln.payments, id: \.self) { payment in
            let type = payment.paymentType == .sent ? "Sent" : "Received"
            
            HStack {
                Text(type)
                Spacer()
                Text("\(payment.amountMsat.sats)")
            }
        }
        .onBackground {
            Task {
                do {
                    try await ln.stop()
                    message = "Stopped"
                } catch {
                    print("Failed to stop node")
                }
            }
        }
        .onForeground {
            Task {
                do {
                    try await ln.start()
                    message = "Started"
                } catch {
                    print("Failed to stop node")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
