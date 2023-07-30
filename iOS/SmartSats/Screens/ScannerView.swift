//
//  ScannerView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/24.
//

import SwiftUI
import CodeScanner

struct ScannerView: View {
    @ObservedObject var ln = LN.shared
    @Environment(\.dismiss) private var dismiss
    
    @State var message = ""
    
    var body: some View {
        CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { response in
            switch response {
            case .success(let result):
                onScan(result.string)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .overlay {
            VStack {
                Spacer()
                if message != "" {
                    Text(message)
                        .foregroundColor(Color.brandAccent2)
                        .padding()
                        .padding()
                        .background(.black)
                        .cornerRadius(12)
                        .padding()
                }
                
                AsyncButton(title: "Paste") {
                    message = ""
                    guard let data = clipboard() else {
                        
                        //Clitch, try again
                        guard let data = clipboard() else {
                            message = "Empty clipboard"
                            return
                        }
                        
                        onScan(data)
                        return
                    }
                    
                    onScan(data)
                }
                .padding(40)
            }
        }
        .ignoresSafeArea(.all)
    }
    
    func onScan(_ data: String) {
        Task {
            do {
                let type = try await ln.decode(data)
                switch type {
                case .bolt11(let invoice):
                    print(invoice)
                    message = "Paying \(invoice.amountMsat?.sats ?? 0) sats..."
                    //TODO disable if people use shared seed
                    let res = try await ln.pay(invoice.bolt11)
                   
                    message = res.pending ? "Pending" : "Success!"
                    break
                case .bitcoinAddress(address: let address):
                    print(address)
                    break
                case .nodeId(nodeId: let nodeId):
                    print(nodeId)
                    break
                case .url(url: let url):
                    print(url)
                    break
                case .lnUrlPay(data: let data):
                    print(data)
                    break
                case .lnUrlWithdraw(data: let data):
                    print(data)
                    break
                case .lnUrlAuth(data: let data):
                    print(data.action ?? "No ACTION")
                    break
                case .lnUrlError(data: let data):
                    print(data)
                    break
                }
                dismiss()
            } catch {
                message = error.localizedDescription
            }
        }
    }
}

struct Scanner_Previews: PreviewProvider {
    static var previews: some View {
        ScannerView()
    }
}
