//
//  LN.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/07.
//

import Foundation
import BreezSDK

fileprivate class SDKListener: EventListener {
    func onEvent(e: BreezEvent) {
        LN.shared.handleEvent(e)
    }
}

fileprivate class SDKLogs: LogStream {
    func log(l: LogEntry) {
        guard l.level != "TRACE" else { return }
        guard l.level != "DEBUG" else { return }
        print("SDK (\(l.level)): \(l.line)")
    }
}

//Used to throw an error with relevent message caught from SdkError
struct SdkDisplayError: LocalizedError {
    var message: String
    var errorDescription: String? {
        return NSLocalizedString(message, comment: "")
    }
}

enum LNErrors: Error {
    case missingSeed
    case missingStorage
    case missingCredentials
    case missingApiKey
    case missingMnumonic
    case missingInviteCode
    case sdkNotSet
}

extension LNErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingSeed:
            return NSLocalizedString("Missing auto generated seed", comment: "Seed failed to be fetched from keychain")
        case .missingStorage:
            return NSLocalizedString("Missing storage directory", comment: "Storage required for setting up SDK")
        case .missingApiKey:
            return NSLocalizedString("Missing API key", comment: "API key setting up SDK")
        case .missingCredentials:
            return NSLocalizedString("Missing greenlight credentials", comment: "Register or recover")
        case .missingMnumonic:
            return NSLocalizedString("Missing mnumonic", comment: "Mnumonic set in onboarding")
        case .missingInviteCode:
            return NSLocalizedString("Missing Greenlight invite code", comment: "Invite code set in onboarding")
        case .sdkNotSet:
            return NSLocalizedString("SDK not set (node not started)", comment: "User needs to start the node")
        }
    }
}

let processInfo = ProcessInfo()

class LN: ObservableObject {
    public static var shared = LN()
    
    private var sdk: BlockingBreezServices?
    private let queue = DispatchQueue(label: "greenlight")

    private let network: Network = .bitcoin
    
    @Published var synced = false
    @Published var nodeInfo: NodeState?
    @Published var payments: [Payment] = []
    @Published var successfulPaymentsInThisSession: [Payment] = [] //For the background task if it's receiving multiple payments and we want a tally

    private var greenlightCredentials: GreenlightCredentials? {
        get {
            guard let key = KeyChain.load(key: .glDeviceKey), let cert = KeyChain.load(key: .glDeviceCert) else {
                return nil
            }
            
            return GreenlightCredentials(deviceKey: [UInt8](key), deviceCert: [UInt8](cert))
        }
        
        set {
            do {
                if let cred = newValue {
                    try KeyChain.save(key: .glDeviceCert, data: Data(cred.deviceCert))
                    try KeyChain.save(key: .glDeviceKey, data: Data(cred.deviceKey))
                }
            } catch {
                print("FAILED TO SAVE TO KEYCHAIN")
                fatalError(error.localizedDescription)
            }
        }
    }
    
    var hasNode: Bool {
        greenlightCredentials != nil && cachedSeed != nil
    }
    
    private var cachedSeed: [UInt8]? {
        if let seed = KeyChain.load(key: .nodeSeed) {
            return [UInt8](seed)
        }
        
        return nil
    }
    
    //TODO allow user to generate mnumonic and get seed from that
//    private func createSeed() throws -> [UInt8] {
//        let newSeed = try generateRandomBytes(count: 64)
//        KeyChain.save(key: .nodeSeed, data: Data(newSeed))
//        return newSeed
//    }
    
    private lazy var storage: String? = {
        let fileManager = FileManager.default
                
        guard let path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.smartsats")?.appendingPathComponent("breez").path else {
            return nil
        }
                
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        
        return path
    }()
    
    private init() {
        do {
            if let mnumonic = processInfo.environment["PHRASE"] {
                try KeyChain.saveStr(key: .mnumonic, str: mnumonic)
            }
            
            if let apiKey = processInfo.environment["API_KEY"] {
                try KeyChain.saveStr(key: .breezApiKey, str: apiKey)
            }
            
            if let inviteCode = processInfo.environment["INVITE_CODE"] {
                try KeyChain.saveStr(key: .glInviteCode, str: inviteCode)
            }
        } catch {
            print("FAILED TO SAVE TO KEYCHAIN")
            fatalError(error.localizedDescription)
        }
                
        queue.async {
            do {
                try setLogStream(logStream: SDKLogs())
            } catch {
                print("WARNING: Failed to set log stream")
            }
        }
    }
    
    fileprivate func handleEvent(_ e: BreezEvent) {
        print("received event ", e)
        
        DispatchQueue.main.async {
            switch e {
            case .synced:
                self.synced = true
                break
            case .newBlock(let block):
                print(block)
                break
            case .backupStarted:
                break
            case .backupSucceeded:
                break
            case .backupFailed(let details):
                print(details)
                break
            case .invoicePaid(let details):
                print(details.paymentHash)
                break
            case .paymentFailed(let details):
                print("PAYMENT FAILED: " + details.error)
                break
            case .paymentSucceed(let details):
                print("***SUCCCESS***")
                print(details)
                self.successfulPaymentsInThisSession.append(details)
                break
            }
            
            self.syncUI()
        }
    }
    
    /// Syncs all node details to published vars from UI thread
    private func syncUI() {
        DispatchQueue.main.async {
            self.nodeInfo = try? self.sdk?.nodeInfo()
            if let payments = try? self.sdk?.listPayments(filter: .all, fromTimestamp: nil, toTimestamp: nil) {
                self.payments = payments
            }
        }
    }
    
    func register() async throws {
        return try await background {
            guard let mnemonic = KeyChain.loadString(key: .mnumonic) else {
                throw LNErrors.missingMnumonic
            }
            
            guard let inviteCode = KeyChain.loadString(key: .glInviteCode) else {
                throw LNErrors.missingInviteCode
            }
            
            let seed = try mnemonicToSeed(phrase: mnemonic)
            try KeyChain.save(key: .nodeSeed, data: Data(seed))
            print("Registering node...")
            self.greenlightCredentials = try registerNode(
                network: self.network,
                seed: seed,
                registerCredentials: nil,
                inviteCode: inviteCode
            )
            print("Registered")
        }
    }
    
    func recover() async throws {
        return try await background {
            print("Recovering...")
            
            guard let mnemonic = KeyChain.loadString(key: .mnumonic) else {
                throw LNErrors.missingMnumonic
            }
            
            let seed = try mnemonicToSeed(phrase: mnemonic)
            try KeyChain.save(key: .nodeSeed, data: Data(seed))
            self.greenlightCredentials = try recoverNode(network: self.network, seed: seed)
            print("Recovered")
        }
    }
    
    func start() async throws {
        guard let greenlightCredentials else {
            throw LNErrors.missingCredentials
        }
        
        guard let storage else {
            throw LNErrors.missingStorage
        }
        
        print("Starting up...")
        synced = false
        
        return try await background {
            var config = defaultConfig(envType: EnvironmentType.production)
            config.workingDir = storage
            guard let apiKey = KeyChain.loadString(key: .breezApiKey) else {
                throw LNErrors.missingApiKey
            }
            
            config.apiKey = apiKey
            config.network = self.network
            
            guard let seed = self.cachedSeed else {
                throw LNErrors.missingSeed
            }
            
            print("Initializing services...")
            self.sdk = try initServices(config: config, seed: seed, creds: greenlightCredentials, listener: SDKListener())
            
            try self.sdk!.start()
            print("Started")
            
            self.syncUI()
        }
    }
    
    func stop() async throws {
        guard sdk != nil else { return }
        return try await background {
            print("Stopping node...")
            try self.sdk?.stop()
            self.sdk = nil
            
            print("Stopped")
            self.syncUI()
            self.synced = false
        }
    }
    
//    func sync() async throws {
//        guard let sdk else { throw LNErrors.sdkNotSet }
//
//        return try await background {
//            try sdk.sync()
//        }
//    }
    
    func receive(amountSats: UInt64, description: String) async throws -> LnInvoice {
        guard let sdk else { throw LNErrors.sdkNotSet }
        return try await background {
            return try sdk.receivePayment(amountSats: amountSats, description: description)
        }
    }
    
    func pay(_ bolt11: String, amountSats: UInt64? = nil) async throws -> Payment {
        guard let sdk else { throw LNErrors.sdkNotSet }
        return try await background {
            return try sdk.sendPayment(bolt11: bolt11, amountSats: amountSats)
        }
    }
    
    func lsp() async throws -> LspInformation? {
        guard let sdk else { throw LNErrors.sdkNotSet }
        return try await background {
            guard let lsp = try sdk.lspId() else {
                return nil
            }
            
            return try sdk.fetchLspInfo(lspId: lsp)
        }
    }
    
    private func background<T>(_ blocking: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let res = try blocking()
                    continuation.resume(with: .success(res))
                } catch let sdkError as SdkError {
                    switch sdkError as SdkError {
                    case .Error(let message):
                        print("SdkError: \(message)")
                        continuation.resume(throwing: SdkDisplayError(message: message))
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
