//
//  AgentSummaryCard.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI

struct AgentSummaryCard: View {
    var agent: Agent?
    @Binding var isCompact: Bool
    var isAddNew = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: isCompact ? 10 : 20)
                .fill(.black.opacity(0.2))
                .blendMode(.overlay)
                .frame(maxHeight: .infinity)
                .overlay(
                    Image(systemName: isAddNew ? "plus.viewfinder" : "person.and.background.dotted")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                )
            Text(agent?.name ?? "Add Agent")
                .fontWeight(.semibold)
                .minimumScaleFactor(0.6)
                .foregroundStyle(Color.brandTextPrimary)
                .padding(.top, 8)
                .layoutPriority(1)
            
            if !isCompact {
                Text(agent != nil ? "\(agent!.usedBudget) / \(agent!.totalBudget) sats" : "Tap to open demo agent in the brower")
                    .font(.caption.weight(.light))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.brandTextSecondary.opacity(0.9))
                    .lineLimit(3)
            }
        }
        .padding(isCompact ? 10 : 14)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .backgroundColor(opacity: isCompact ? 0.3 : 0.5, cornerRadius: isCompact ? 10 : 20)
        .cornerRadius(isCompact ? 10 : 20)
        .modifier(OutlineModifier(cornerRadius: isCompact ? 10 : 20))
        .frame(width: 220)
        .shadow(
            color: Color.shadow.opacity(0.25),
            radius: 5, x: 0, y: 3
        )
    }
}

struct AgentSummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        AgentSummaryCard(agent: .init(id: "agent_1", name: "Agent 1", description: "Bla bla bla", pushServerId: "", totalBudget: 500, usedBudget: 100), isCompact: .constant(false))
    }
}
