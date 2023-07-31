//
//  AgentView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/31.
//

import SwiftUI

struct AgentView: View {
    @Binding var agent: Agent
    
    @ObservedObject var agents = Agents.shared
    @Environment(\.dismiss) private var dismiss
    
    @State var errorMessage = ""
    @State var showError = false
    
    var body: some View {
        VStack {
            Text(agent.name)
                .multilineTextAlignment(.center)
                .font(.largeTitle)
            
            Text(agent.description)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            #if DEBUG
            Text("\(agent.pushServerId)")
            #endif
            
            Image(systemName: "person.and.background.dotted")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.brandAccent1)
                .frame(height: 140)
                .padding()
            
            Text("\(agent.usedBudget) / \(agent.totalBudget) sats")
                .font(.title3)
                .bold()
            
//            AsyncButton(title: "Test Deduct") {
//                agents.deductFromAgent(agent, amount: 20)
//            }
            
            Spacer()
            
            Text("Unlinking will prevent the agent from making any future deductions from your wallet")
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
            AsyncButton(title: "Unlink Agent") {
                do {
                    try await agents.deleteAgent(agent)
                    dismiss()
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage))
        }
        .padding()
    }
}

struct AgentView_Previews: PreviewProvider {
    static var previews: some View {
        AgentView(agent: .constant(.init(id: "id", name: "Wev Dev Demo", description: "The cheapest web dev around", pushServerId: "", totalBudget: 500, usedBudget: 20)))
    }
}
