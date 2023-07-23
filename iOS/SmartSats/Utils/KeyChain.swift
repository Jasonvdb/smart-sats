//
//  KeyChain.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/07.
//

import Foundation
import Security

enum KeyChainErrors: Error {
    case failedToSave
}

class KeyChain {
    private static let group = "BJJ5WGNUJH.jasonvdb.smartsats"
    
    enum KeyChainKey: String {
        case glDeviceCert = "gl-device-cert2"
        case glDeviceKey = "gl-device-key2"
        case nodeSeed = "node-seed2"
        
        //Saved in onboarding
        case breezApiKey = "breez-api-key2"
        case glInviteCode = "gl-invite-code2"
        case mnumonic = "mnumonic2"
    }
    
    class func save(key: KeyChainKey, data: Data) throws {
        print(key.rawValue)

        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock as String,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessGroup as String: Self.group
        ] as [String : Any]
        
        let deleteStatus = SecItemDelete(query as CFDictionary)
        print("DELETE STATUS: \(deleteStatus)")
        let status = SecItemAdd(query as CFDictionary, nil)
        
        print("SAVE STATUS \(status)")
        
        if status != noErr {
            throw KeyChainErrors.failedToSave
        }
    }
    
    class func saveString(key: KeyChainKey, str: String) throws {
        guard let data = str.data(using: .utf8) else {
            throw KeyChainErrors.failedToSave
        }
        
        try save(key: key, data: data)
    }
    
    
    class func delete(key: KeyChainKey) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key.rawValue,
            kSecAttrAccessGroup as String: Self.group
        ] as [String : Any]
        
        SecItemDelete(query as CFDictionary)
    }
    
    class func load(key: KeyChainKey) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: Self.group
        ] as [String : Any]
        
        var dataTypeRef: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            print(key.rawValue + " loaded from keychain")
            return dataTypeRef as! Data?
        } else {
            print(key.rawValue + " ERROR " + status.description)

            return nil
        }
    }
    
    class func loadString(key: KeyChainKey) -> String? {
        if let data = load(key: key), let str = String(data: data, encoding: .utf8) {
           return str
        }
        
        return nil
    }
    
    class func wipe() {
        #if DEBUG
        delete(key: .glDeviceCert)
        delete(key: .glDeviceKey)
        delete(key: .nodeSeed)
        delete(key: .mnumonic)
        delete(key: .breezApiKey)
        #else
        print("Debug only")
        #endif
    }
}
