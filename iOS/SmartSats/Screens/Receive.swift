//
//  Receive.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/09.
//

import SwiftUI

struct Receive: View {
    @Binding var invoice: String
    
    var body: some View {
        VStack {
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
        }
    }
}

struct Receive_Previews: PreviewProvider {
    static var previews: some View {
        Receive(invoice: .constant("lnbc2u1pj2465ypp5d7ygtjeuws7kmglccr26mgdhag05m66g79t7pcfzursufyl4vr6sdqdw3jhxar9v4jk2cqzzsxqrrsssp5tmpntm20sf5wzdwuu76uksh5ph0y8vgyp3ervzvd8cdvtdjcncqq9qyyssqz8m2qm9j359qeshgf66xlq6k5qys0nzjn56s6azqxn8kl5uv8y69ph7a2eaxlz4gjs22sm2trr3w6hqwneu47amr79vdzslqxyxwxjspwrf5m9"))
    }
}
