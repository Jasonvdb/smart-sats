//
//  NotificationService.swift
//  SmartSatsPushNotification
//
//  Created by Jason van den Berg on 2023/07/11.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    let ln = LN.shared

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    var title: String?
    var body: String?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
              
        Task {
            
            do {
                guard let aps = request.content.userInfo["aps"] as? AnyObject else {
                    body = "Invalid request"
                    deliver()
                    return
                }
                
                let charge = try Charge(aps: aps)
                
                try await ln.start()
                
                let pay = try await ln.pay(charge.bolt11)

                title = "Demo charged \(pay.amountMsat.sats) sats"
                body = pay.description
            } catch {
                title = "Charge failed"
                body = error.localizedDescription
            }

            deliver()

        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        deliver()
    }
    
    func deliver() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            if let title = self.title {
                bestAttemptContent.title = title
            }
            
            if let body = self.body {
                bestAttemptContent.body = body
            }
            
            contentHandler(bestAttemptContent)
        }
    }

}
