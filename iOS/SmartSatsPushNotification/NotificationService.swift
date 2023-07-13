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
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
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
                
                try await ln.start()
                
                //TODO check if it's been paid before
        
                let pay = try await ln.pay(charge.bolt11)

                title = "Demo charged \(pay.amountMsat.sats) sats ⚡"
                body = pay.description
                deliver()
            } catch {
                if error.localizedDescription.contains("payment not found") {
                    title = "Probably paid"
                    body = error.localizedDescription
                    //Don't deliver, let the timeout tell the user how much was charged
                } else {
                    title = "Charge failed..."
                    body = error.localizedDescription
                    deliver()
                }
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        //Check if we timed out but did receive one or more payments
        let paymentCount = ln.successfulPaymentsInThisSession.count
        if paymentCount > 0 {
            //TODO get the total payments
            var totalMSats: UInt64 = 0
        
            ln.successfulPaymentsInThisSession.forEach { payment in
                totalMSats += payment.amountMsat
            }
            
            title = "Charged \(totalMSats.sats) sats ⚡"
            body = "Charged \(paymentCount) payment\(paymentCount > 1 ? "s" : "")"
        } else {
            body = "Timeout (\(ln.synced ? "Synced" : "Not synced"))"
        }
        deliver()
    }
    
    func deliver() {
        Task {
            try? await ln.stop()
        }
        
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            if let title = self.title {
                bestAttemptContent.title = title
            }
            
            // Your function code here
            
            let endTime = DispatchTime.now()
            let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let elapsedTimeInSeconds = Double(elapsedTime) / 1_000_000_000.0
            
            if let body = self.body {
                bestAttemptContent.body = body + " [\(elapsedTimeInSeconds)]"
            }
            
            contentHandler(bestAttemptContent)
        }
    }

}
