//
//  Payment.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/12.
//

import Foundation
import BreezSDK

extension Payment {
    var displayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date(timeIntervalSince1970: TimeInterval(paymentTime))
        return dateFormatter.string(from: date)
    }
    
    var lnData: LnPaymentDetails? {
        switch details {
        case .ln(let data):
            return data
        case .closedChannel(_):
            return nil
        }
    }
    
    var displayType: String {
        switch paymentType {
        case .closedChannel:
            return "Closed channel"
        case .received:
            return "Received"
        case .sent:
            return "Sent"
        }
    }
}
