//
//  KeyChain.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/07.
//

import Foundation
import Security

class KeyChain {
    enum KeyChainKey: String {
        case glDeviceCert = "gl-device-cert"
        case glDeviceKey = "gl-device-key"
        case nodeSeed = "node-seed"
    }
    
    class func save(key: KeyChainKey, data: Data) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    class func delete(key: KeyChainKey) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key.rawValue
        ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
    }
    
    class func load(key: KeyChainKey) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne ] as [String : Any]
        
        var dataTypeRef: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }
    
    class func wipe() {
        #if DEBUG
        delete(key: .glDeviceCert)
        delete(key: .glDeviceKey)
        delete(key: .nodeSeed)
        #else
        print("Debug only")
        #endif
    }
}
