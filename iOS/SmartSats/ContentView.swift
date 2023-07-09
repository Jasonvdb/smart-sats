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
    
    @State var receiveInvoice = ""
    @State var showReceive = false
    
    var body: some View {
        VStack {
            if let info = ln.nodeInfo {
                Text("Block height: \(info.blockHeight)")
                Text("Channel balance: \(info.channelsBalanceMsat.sats)")
                Text("Onchain balance: \(info.onchainBalanceMsat.sats)")
                Text("Peers: \(info.connectedPeers.joined(separator: ", "))")
            }
            
            Text(displayError).foregroundColor(.red).font(.footnote)
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
                    let sats = UInt64((arc4random_uniform(31)) + 20)
                    let res = try await ln.receive(amountSats: 5000, description: "Testing UI")
                    receiveInvoice = res.bolt11
                    showReceive = true
                } catch  {
                    displayError = error.localizedDescription
                }
            }
            
            AsyncButton(title: "Pay") {
                displayError = ""
                do {
                    guard let inv = clipboard() else {
                        message = "Empty clipboard"
                        return
                    }
                    
                    let res = try await ln.pay(inv)
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
        .sheet(isPresented: $showReceive, content: {
            Receive(invoice: $receiveInvoice)
        })
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
