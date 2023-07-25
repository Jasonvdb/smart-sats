//
//  DebugView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI
import BreezSDK

struct DebugView: View {
    @ObservedObject var ln = LN.shared
    @State var displayError = ""
    @State var message = ""
    
    @State var receiveInvoice = ""
    @State var showReceive = false
    
    @State var showTransaction = false
    @State var selectedPayment: Payment = dummyPayment

    var body: some View {
        VStack {
            if let info = ln.nodeInfo {
                Text("Block height: \(info.blockHeight)")
                Text("Channel balance: \(info.channelsBalanceMsat.sats)")
                Text("Onchain balance: \(info.onchainBalanceMsat.sats)")
                Text("Synced: \(ln.synced ? "✅" : "⏳")")
            }
            
            Text(displayError)
                .foregroundColor(.red)
                .font(.footnote)
            Text(message)
                .foregroundColor(.green)
            Text("Received payments: \($ln.successfulPaymentsInThisSession.count)")
            
            if !ln.hasNode {
                AsyncButton(title: "Connect node") {
                    displayError = ""
                    do {
                        try await ln.connect()
                        message = "Node registered"
                    } catch  {
                        displayError = error.localizedDescription
                    }
                }
            }
            
            AsyncButton(title: "Setup background charges") {
                requestPushNotificationPermision { success, error in
                    guard error == nil else {
                        displayError = error!.localizedDescription
                        return
                    }
                    
                    message = "Background charges setup"
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
                    let res = try await ln.receive(amountSats: 100, description: "Testing UI")
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
            HStack {
                VStack(alignment: .leading) {
                    Text("\(payment.displayType) \(payment.pending ? "⏳" : "")")
                    Text(payment.description ?? "")
                        .font(.caption)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(payment.amountMsat.sats)")
                    Text("\(payment.displayTime)")
                        .font(.caption2)
                }
            }
            .onTapGesture {
                selectedPayment = payment
                showTransaction = true
            }
        }
//        .sheet(isPresented: $showReceive, content: {
//            ReceiveView(invoice: $receiveInvoice)
//        })
        .sheet(isPresented: $showTransaction, content: {
            TransactionView(payment: $selectedPayment)
        })
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
