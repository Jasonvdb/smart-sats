//
//  AgentSummaryCard.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI

struct AgentSummaryCard: View {
    var agent: Agent
    @Binding var isCompact: Bool

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: isCompact ? 10 : 20)
                .fill(.black.opacity(0.2))
                .blendMode(.overlay)
                .frame(maxHeight: .infinity)
                .overlay(
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                )
            Text(agent.name)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.6)
                .foregroundStyle(Color.brandTextPrimary)
                .padding(.top, 8)
                .layoutPriority(1)
            
            if !isCompact {
                Text("Last used 1 hour ago")
                    .font(.caption.weight(.light))
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(Color.brandTextSecondary)
                Spacer()
                Text(agent.description)
                    .font(.caption.weight(.light))
                    .foregroundStyle(Color.brandTextSecondary.opacity(0.8))
                    .lineLimit(3)
            }
        }
        .padding(isCompact ? 10 : 14)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .backgroundColor(opacity: isCompact ? 1 : 0.5, cornerRadius: isCompact ? 10 : 20)
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
        AgentSummaryCard(agent: .init(name: "Agent 1", description: "Bla bla bla"), isCompact: .constant(false))
    }
}
