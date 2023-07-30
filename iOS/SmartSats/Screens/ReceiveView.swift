//
//  ReceiveView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/09.
//

import SwiftUI

struct ReceiveView: View {
    @ObservedObject var ln = LN.shared

    @State var invoice: String?
    @State var sats: UInt64 = 500

    var body: some View {
        VStack {
            if let invoice {
                Text("\(sats) sats")
                    .font(.title)
                    .padding()
                if let qr = invoice.qr {
                    Image(uiImage: qr)
                        .resizable()
                        .interpolation(.none)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                Button {
                    UIPasteboard.general.string = invoice
                } label: {
                    Text(invoice)
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .padding()
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                let res = try await ln.receive(amountSats: sats, description: "Testing UI")
                invoice = res.bolt11
            }
        }
    }
}

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveView()
    }
}
