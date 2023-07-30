//
//  NodeInfoView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/27.
//

import SwiftUI
import BreezSDK

struct NodeInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel = ViewModel.shared
    @ObservedObject var ln = LN.shared

    @State var lsp: LspInformation?
    @State var devResult = ""
    
    var body: some View {
        NavigationView {
            List {
                if let info = ln.nodeInfo {
                    Section("Details") {
                        Label("Node ID: \(info.id)", systemImage: "key.horizontal")
                            .tint(Color.brandTextPrimary)
                        Label("Block height: \(info.blockHeight)", systemImage: "bitcoinsign")
                            .tint(Color.brandTextPrimary)
                        Label("Inbound liquidity: \(info.inboundLiquidityMsats.sats) sats", systemImage: "drop")
                            .tint(Color.brandTextPrimary)
                        Label("Max payable: \(info.maxPayableMsat.sats) sats", systemImage: "drop")
                            .tint(Color.brandTextPrimary)
                        Label("Max receivable: \(info.maxReceivableMsat.sats) sats", systemImage: "drop")
                            .tint(Color.brandTextPrimary)
                        Label("Max single payment: \(info.maxSinglePaymentAmountMsat.sats) sats", systemImage: "drop")
                            .tint(Color.brandTextPrimary)
                    }
                    
                    Section("Peers") {
                        ForEach(info.connectedPeers, id: \.self) { peer in
                            Label(peer, systemImage: "person.line.dotted.person")
                                .tint(Color.brandTextPrimary)
                        }
                    }
                }
                
                if let lsp {
                    Section("LSP") {
                        Label(lsp.name, systemImage: "cloud")
                            .tint(Color.brandTextPrimary)
                        Label(lsp.pubkey, systemImage: "key.horizontal")
                            .tint(Color.brandTextPrimary)
                        Label("Host: \(lsp.host)", systemImage: "network")
                            .tint(Color.brandTextPrimary)
                        Label("Fee rate: \(lsp.feeRate)", systemImage: "dollarsign.arrow.circlepath")
                            .tint(Color.brandTextPrimary)
                        Label("Channel min fee: \(lsp.channelMinimumFeeMsat) msats", systemImage: "dollarsign")
                            .tint(Color.brandTextPrimary)
                    }
                }
                
//                Section {
//                    Button {
//                        Task {
//                            do {
//                                // case 'listPeers':
//                                // case 'listFunds':
//                                // case 'listPayments':
//                                // case 'listInvoices':
//                                // case 'closeAllChannels':
//                                guard let res = try await ln.dev("listsendpays") else {
//                                    devResult = "No result"
//                                    return
//                                }
//                                
//                                devResult = res
//                            } catch {
//                                devResult = error.localizedDescription
//                            }
//                        }
//                    } label: {
//                        Label("Debug", systemImage: "ladybug")
//                            .tint(Color.brandTextPrimary)
//                    }
//                }
                
                if devResult != "" {
                    Text(devResult)
                        .font(.caption2)
                        .foregroundColor(.green)
                        .background(.black)
                }
            }
            .listStyle(.insetGrouped)
            .tint(Color.brandAccent1)
            .navigationTitle(ln.synced ? "Node Synced" : "Syncing...")
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }, label: {
                Text("Done")
                    .foregroundColor(Color.brandTextSecondary)
            }))
        }
        .onAppear {
            Task {
                lsp = try? await ln.lsp()
            }
        }
    }
}

struct NodeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NodeInfoView()
    }
}
