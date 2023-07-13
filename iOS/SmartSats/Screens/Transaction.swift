//
//  Transaction.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/12.
//

import SwiftUI
import BreezSDK

struct Transaction: View {
    @Binding var payment: Payment
    
    var body: some View {
        VStack {
            Text(payment.displayType)
            Text("\(payment.amountMsat.sats) sats").font(.title)
            Text(payment.displayTime)
            Text(payment.description ?? "")
            Text("Fee: \(payment.feeMsat.sats) sats")
            Text(payment.pending ? "Pending" : "Confirmed")
            Text(payment.id).font(.caption2)
        }
        .padding()
    }
}

struct Transaction_Previews: PreviewProvider {
    static var previews: some View {
        Transaction(payment: .constant(dummyPayment))
    }
}

let dummyPayment: Payment = .init(
    id: "id",
    paymentType: .received,
    paymentTime: 0,
    amountMsat: 123,
    feeMsat: 1,
    pending: false,
    description: "Description",
    details: .closedChannel(data: .init(shortChannelId: "", state: .closed, fundingTxid: ""))
)
