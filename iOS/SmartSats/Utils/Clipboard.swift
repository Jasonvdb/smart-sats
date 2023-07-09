//
//  Clipboard.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/09.
//

#if os(iOS)
import UIKit

func clipboard() -> String? {
    return UIPasteboard.general.string
}

#else

import AppKit
func clipboard() -> String? {
    if let data = NSPasteboard.general.data(forType: .string),
       let string = String(data: data, encoding: .utf8) {
        return string
    }
    return nil
}

#endif

