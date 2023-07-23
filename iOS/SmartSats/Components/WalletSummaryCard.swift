//
//  WalletSummaryCard.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI

struct WalletSummaryCard: View {
    @Binding var isCompact: Bool
    
    @ObservedObject var ln = LN.shared
    
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack(alignment: .center, spacing: isCompact ? 4 : 8) {
            if let info = ln.nodeInfo {
                Text("\((info.channelsBalanceMsat + info.onchainBalanceMsat).sats) sats")
                    .font(.system(size: isCompact ? 40 : 50)).bold()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                if !isCompact {
                    VStack {
                        Text("Channel balance: \(info.channelsBalanceMsat.sats)")
                            .font(.caption.weight(.semibold))
                            .minimumScaleFactor(0.8)
                            .foregroundStyle(Color.brandTextSecondary)
                        Text("On chain balance: \(info.onchainBalanceMsat.sats)")
                            .font(.caption.weight(.semibold))
                            .minimumScaleFactor(0.8)
                            .foregroundStyle(Color.brandTextSecondary)
                        Text("Block height: \(info.blockHeight)")
                            .font(.footnote)
                            .minimumScaleFactor(0.8)
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                    .padding(.top)
                }
            } else {
                Text("---")
                    .font(.system(size: 100)).bold()
                    .minimumScaleFactor(0.4)
            }
        }

        .padding(isCompact ? 12 : 20)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .backgroundColor(opacity: 0.5)
        .cornerRadius(20)
        .modifier(OutlineModifier(cornerRadius: 20))
        .shadow(
            color: Color.shadow.opacity(0.3),
            radius: 10, x: 0, y: 5
        )
    }
}

struct WalletSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        WalletSummaryCard(isCompact: .constant(false))
    }
}
