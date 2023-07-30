//
//  Haptics.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/26.
//

import UIKit

class Haptics {
    static func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle, withDelay: Double = 0) {
        let i = UIImpactFeedbackGenerator(style: feedbackStyle)
        i.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + withDelay) {
            i.impactOccurred()
        }
    }
    
    static func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
