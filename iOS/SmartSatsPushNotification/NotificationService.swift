//
//  NotificationService.swift
//  SmartSatsPushNotification
//
//  Created by Jason van den Berg on 2023/07/11.
//

import UserNotifications
import BreezSDK

class NotificationService: UNNotificationServiceExtension {
    let ln = LN.shared

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    var title: String?
    var body: String?
    let startTime = DispatchTime.now()
    var requestedAmount: UInt64 = 0
    var invoiceDescription: String?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        ln.isInForeground = false

        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        print("**********BACKGROUND***********")
        
        Task {
            do {
                guard let aps = request.content.userInfo["aps"] as? AnyObject else {
                    body = "Invalid request"
                    deliver()
                    return
                }
                
                let charge = try Charge(aps: aps)
                
                try await ln.connect()
                if !ln.synced {
                    try await ln.sync()
                    await waitForSync()
                }
                
                let decode = try await ln.decode(charge.bolt11)
                switch decode {
                case .bolt11(let invoice):
                    if let amount = invoice.amountMsat?.sats {
                        requestedAmount += amount
                    }
                    invoiceDescription = invoice.description
                default:
                    title = "Payment failed"
                    body = "Received invalid invoice"
                    break
                }
                
                let pay = try await ln.pay(charge.bolt11)

                title = "Demo charged \(pay.amountMsat.sats) sats ⚡"
                body = pay.description
                deliver()
            } catch {
                if error.localizedDescription.contains("payment not found") {
                    title = "Probably paid \(requestedAmount))"
                    body = invoiceDescription
                } else {
                    title = "Charge failed..."
                    body = error.localizedDescription
                }
                deliver()
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        title = "Agent requested a charge"
        if requestedAmount > 0 {
            body = "Timeout paying \(requestedAmount) sats. Please open the app to make sure payment was processed."
        } else {
            body = "Timeout (\(ln.synced ? "Synced" : "Not synced"))"
        }
        deliver()
    }
    
    func deliver() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            if let title = self.title {
                bestAttemptContent.title = title
            }
            
            // Your function code here
            
            let endTime = DispatchTime.now()
            let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let elapsedTimeInSeconds = Double(elapsedTime) / 1_000_000_000.0
            
            if let body = self.body {
                bestAttemptContent.body = body//  + " [\(elapsedTimeInSeconds)]"
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    func waitForSync() async {
        while !ln.synced {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }
}
