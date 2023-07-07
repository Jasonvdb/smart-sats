//
//  UInt64.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/07.
//

import Foundation

extension UInt64 {
    var sats: UInt64 {
        self / 1000
    }
}
