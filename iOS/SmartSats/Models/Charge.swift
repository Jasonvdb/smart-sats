//
//  Charge.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/12.
//

import Foundation

enum ChargeErrors: Error {
    case invalidAps
}

struct Charge {
    let bolt11: String
    let auth: String
    
    init(aps: AnyObject) throws {
        guard
            let alert = aps["alert"] as? AnyObject,
            let payload = alert["payload"] as? AnyObject,
            let bolt11 = payload["bolt11"] as? String,
            let auth = payload["auth"] as? String else {
            throw ChargeErrors.invalidAps
        }
        
        self.bolt11 = bolt11
        self.auth = auth
    }    
}
