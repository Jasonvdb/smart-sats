//
//  SettingsView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel = ViewModel.shared
    
    var body: some View {
        NavigationView {
            List {
                settings
                links
            }
            .listStyle(.insetGrouped)
            .tint(Color.brandAccent1)
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }, label: {
                Text("Done")
                    .foregroundColor(Color.brandTextSecondary)
            }))
        }
    }
    
    var settings: some View {
        Section("Settings") {
            HStack {
                Toggle(isOn: .constant(true)) {
                    Label("Background payments", systemImage: "bell")
                        .tint(Color.brandTextPrimary)
                }
                .onTapGesture {
                    requestPushNotificationPermision { success, error in
                        print("TODO handle push")
                    }
                }
            }
            
            Button {
                dismiss()
                viewModel.showOnboardingModal = true
                viewModel.selectedOnboardingModal = .intro1
            } label: {
                Label("Reset onboarding", systemImage: "repeat")
                    .tint(Color.brandTextPrimary)
            }
        }
    }
    
    var links: some View {
        Section("Links") {
            Link(destination: URL(string: DEMO_URL)!) {
                HStack {
                    Label("Demo agent", systemImage: "person.and.background.dotted")
                        .tint(Color.brandTextPrimary)
                }
            }
            Link(destination: URL(string: "https://github.com/Jasonvdb/smart-sats")!) {
                HStack {
                    Label("GitHub", systemImage: "link")
                        .tint(Color.brandTextPrimary)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
