//
//  AgentSetupView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/31.
//

import SwiftUI

struct AgentSetupView: View {
    @ObservedObject var agents = Agents.shared
    @ObservedObject var ln = LN.shared
    
    @State private var max: Double = 1
    @State private var budget: Double = 1
    
    @State var errorMessage = ""
    @State var showError = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Agent Setup")
                .font(.largeTitle)
            Spacer()
            Image(systemName: "person.and.background.dotted")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.brandAccent1)
                .frame(height: 140)
            
            Spacer()
            
            Text("\(String(format: "%.0f", budget)) sats")
            Slider(value: $budget, in: 0...max, step: min(100, max))
                .accentColor(Color.brandAccent2)
                .onAppear {
                    if let i = ln.nodeInfo {
                        max = Double(i.channelsBalanceMsat.sats)
                        budget = min(max, 500)
                    }
                }
            HStack {
                Text("Budget")
                Spacer()
                Text("\(String(format: "%.0f", max)) sats")
            }
            Spacer()
            
            
            if agents.pushToken == "" {
                VStack {
                    Text("Push notifications are required for agents to send payment requests")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    AsyncButton(title: "Allow Notifications", action: {
                        requestPushNotificationPermision { success, error in
                            if let error = error {
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    })
                }
            } else {
                VStack {
                    Text("Agent can be unlinked at any time")
                        .font(.caption)
                        .padding()
                    CtaButton(title: "Link Agent") {
                        do {
                            try await agents.registerAgent(budget: UInt64(budget))
                            dismiss()
                        } catch {
                            print(error)
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage))
        }
        .padding()
    }
}

struct AgentSetupView_Previews: PreviewProvider {
    static var previews: some View {
        AgentSetupView()
    }
}
