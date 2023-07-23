//
//  TransactionList.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI
import BreezSDK

struct TransactionList: View {
    let topSpace: CGFloat
    let onScroll: ((CGFloat) -> Void)
    
    @ObservedObject var ln = LN.shared
    @State var showTransaction = false
    @State var selectedPayment: Payment = dummyPayment
    
    var body: some View {
        ScrollView {
            scrollDetection
            VStack {}
                .background(Color.clear)
                .frame(height: topSpace)
            ForEach(ln.payments, id: \.self) { payment in
                TxListItem(payment: payment)
                    .padding(.horizontal)
                .onTapGesture {
                    selectedPayment = payment
                    showTransaction = true
                }
            }
        }
        .coordinateSpace(name: "scroll")
        .sheet(isPresented: $showTransaction, content: {
            TransactionView(payment: $selectedPayment)
        })
    }
    
    var scrollDetection: some View {
        GeometryReader { proxy in
            let offset = proxy.frame(in: .named("scroll")).minY
            Color.clear.preference(key: ScrollPreferenceKey.self, value: offset)
        }
        .onPreferenceChange(ScrollPreferenceKey.self) { offset in
            onScroll(offset)
        }
    }
}

struct TransactionList_Previews: PreviewProvider {
    static var previews: some View {
        TransactionList(topSpace: 0) { y in
            
        }
    }
}
