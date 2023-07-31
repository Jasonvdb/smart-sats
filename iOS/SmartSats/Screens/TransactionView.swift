//
//  Transaction.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/12.
//

import SwiftUI
import BreezSDK

struct TransactionView: View {
    @Binding var payment: Payment
    
    var body: some View {
        VStack {
            title
            
            image
                .padding(20)
            
            amount
            
            Spacer()
            
            
            Text("Note: \(payment.description ?? "")")
                .padding()
            Text(payment.pending ? "Pending" : "Confirmed")
                .padding(2)
            Text(payment.id)
                .font(.system(size: 8))
                .fontWeight(.light)
                .padding(2)
        }
        .padding()
    }
    
    var image: some View {
        var systemName = ""
        var color = Color.blue
        switch payment.paymentType {
        case .received:
            systemName = "arrow.down.forward"
            color = .green
            break
        case .sent:
            systemName = "arrow.up.forward"
            color = .red
            break
        case .closedChannel:
            systemName = "checkmark"
            break
        }
        
        return Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .foregroundColor(color)
            .padding(20)
            .frame(width: 120, height: 120)
            .mask(Circle())
            .padding(12)
            .background(.thinMaterial)
            .mask(Circle())
    }
    
    var title: some View {
        var title = ""
        switch payment.paymentType {
        case .received:
            title = "Received"
            break
        case .sent:
            title = "Paid"
            break
        case .closedChannel:
            title = "Closed channel"
            break
        }
        
        return Text(title)
            .font(.largeTitle)
            .fontWeight(.semibold)
    }
    
    var amount: some View {
        var prefix = ""
        switch payment.paymentType {
        case .received:
            prefix = "+"
            break
        case .sent:
            prefix = "-"
            break
        case .closedChannel:
            break
        }
        
        return VStack {
            Text("\(prefix)\(payment.amountMsat.sats) sats")
                .font(.title2)
                .foregroundStyle(Color.brandTextPrimary)
            Text("Fee: \(payment.feeMsat.sats)")
                .font(.title3.weight(.light))
                .foregroundStyle(Color.brandTextSecondary)
        }
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView(payment: .constant(dummyPayment))
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
