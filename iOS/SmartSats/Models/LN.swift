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

enum LNErrors: Error {
    case missingSeed
    case missingStorage
    case missingCredentials
    case sdkNotSet
}

extension LNErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingSeed:
            return NSLocalizedString("Missing auto generated seed", comment: "Seed failed to be fetched from keychain")
        case .missingStorage:
            return NSLocalizedString("Missing storage directory", comment: "Storage required for setting up SDK")
        case .missingCredentials:
            return NSLocalizedString("Missing greenlight credentials", comment: "Register or recover")
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

    private let phrase = processInfo.environment["PHRASE"]!
    private let apiKey = processInfo.environment["API_KEY"]!
    private let inviteCode = processInfo.environment["INVITE_CODE"]!

    private let network: Network = .bitcoin
    
    @Published var nodeInfo: NodeState?
    @Published var payments: [Payment] = []

    private var greenlightCredentials: GreenlightCredentials? {
        get {
            guard let key = KeyChain.load(key: .glDeviceKey), let cert = KeyChain.load(key: .glDeviceCert) else {
                return nil
            }
            
            return GreenlightCredentials(deviceKey: [UInt8](key), deviceCert: [UInt8](cert))
        }
        
        set {
            if let cred = newValue {
                KeyChain.save(key: .glDeviceCert, data: Data(cred.deviceCert))
                KeyChain.save(key: .glDeviceKey, data: Data(cred.deviceKey))
            }
        }
    }
    
    var hasNode: Bool {
        greenlightCredentials != nil
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
        guard let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "breez").path else {
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
        
        switch e {
        case .synced:
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
            print(details)
            break
        }
        
        self.syncUI()
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
            let seed = try mnemonicToSeed(phrase: self.phrase)
            print("Registering node...")
            self.greenlightCredentials = try registerNode(
                network: self.network,
                seed: seed,
                registerCredentials: nil,
                inviteCode: self.inviteCode
            )
            print("Registered")
        }
    }
    
    func recover() async throws {
        return try await background {
            print("Recovering...")
            let seed = try mnemonicToSeed(phrase: self.phrase)
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
        
        return try await background {
            var config = defaultConfig(envType: EnvironmentType.production)
            config.workingDir = storage
            config.apiKey = self.apiKey
            config.network = self.network
            
            let seed = try mnemonicToSeed(phrase: self.phrase)
            
            print("Initializing services...")
            self.sdk = try initServices(config: config, seed: seed, creds: greenlightCredentials, listener: SDKListener())
            
            print("Starting node...")
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
                    }
                    
                    continuation.resume(throwing: sdkError)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
