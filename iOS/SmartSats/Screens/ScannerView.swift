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
            if message != "" {
                Text(message)
                    .font(.largeTitle)
                    .foregroundColor(Color.brandAccent2)
                    .padding()
            }
        }
        .ignoresSafeArea(.all)
    }
    
    func onScan(_ data: String) {
        Task {
            do {
                message = "Decoding..."
                let type = try await ln.decode(data)
                switch type {
                case .bolt11(let invoice):
                    print(invoice)
                    message = "Paying \(invoice.amountMsat?.sats ?? 0) sats..."
                    //TODO disable if people use shared seed
                    let res = try await ln.pay(invoice.bolt11)
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
                    print(data)
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
