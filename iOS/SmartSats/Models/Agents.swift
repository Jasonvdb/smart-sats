//
//  Agents.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import Foundation
import SwiftUI

let PUSH_SERVER_URL = "https://smartsatspush.intern.cheap"

struct Agent: Hashable, Codable {
    let id: String
    let name: String
    let description: String
    let pushServerId: String
    let totalBudget: UInt64
    let usedBudget: UInt64
}

//enum AgentErrors: Error {
//    case failedToRegisterWithAgent
//}

struct PushServerResponse: Codable {
    let id: String //To revoke from push server later
    let hook: String
}


struct AgentServerResponse: Codable {
    let id: String
    let name: String
    let description: String
}

class Agents: ObservableObject {
    public static var shared = Agents()
    
    private lazy var storage: URL? = {
        let fileManager = FileManager.default
        
        guard var url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.smartsats") else {
            return nil
        }
        
        let path = url.path
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                return nil
            }
        }
        
        return url.appendingPathComponent("agents.bin")
    }()
    
    private init() {
        _ = loadAgents()
    }
    
    @Published var showAgentSetup = false
    @Published var agentRegisterUrl = ""
    @AppStorage("pushToken") var pushToken = ""
    
    func registerAgent(budget: UInt64) async throws {
        print("Registering agent...")
        
        guard let pushServerUrl = URL(string: "\(PUSH_SERVER_URL)/register?token=\(pushToken)") else {
            print("Invalid push server url")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: pushServerUrl) //TODo pass token in request
            
            
            //            let json = try JSONSerialization.jsonObject(with: data, options: [])
            //            // Handle the raw JSON response (json variable)
            //            print("\(json)")
            
            let pushServerResponse = try JSONDecoder().decode(PushServerResponse.self, from: data)
            print(pushServerResponse)
            
            
            //            print(pushServerResponse.hook)
            //TODO send budget and hook
            
            guard let encodedHook = pushServerResponse.hook.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("Failed to url encode charge hook")
                return
            }
            
            guard let agentServerUrl = URL(string: "\(agentRegisterUrl)&budget=\(budget)&hook=\(encodedHook)") else {
                print("Invalid agent server url")
                return
            }
            
            print("Register with agent")
            print(agentServerUrl.path)
            
            let (agentData, _) = try await URLSession.shared.data(from: agentServerUrl) //TODo pass token in request
            
            //            let agentJson = try JSONSerialization.jsonObject(with: agentData, options: [])
            //            // Handle the raw JSON response (json variable)
            //            print("Raw JSON response from agent server: \(json)")
            
            let agentServerResponse = try JSONDecoder().decode(AgentServerResponse.self, from: agentData)
            print(agentServerResponse)
            
            addAgent(
                Agent(
                    id: agentServerResponse.id,
                    name: agentServerResponse.name,
                    description: agentServerResponse.description,
                    pushServerId: pushServerResponse.id,
                    totalBudget: budget,
                    usedBudget: 0
                )
            )
        } catch {
            print("Error: \(error)")
            throw error
        }
    }
    
    func deductFromAgent(_ agent: Agent, amount: UInt64) {
        var freshList = loadAgents()
        let updatedAgent = Agent(
            id: agent.id,
            name: agent.name,
            description: agent.description,
            pushServerId: agent.pushServerId,
            totalBudget: agent.totalBudget,
            usedBudget: agent.usedBudget + amount
        )
        freshList.removeAll { $0.id == agent.id }
        freshList.append(updatedAgent)
        saveAgents(freshList)
    }
    
    func getAgentBy(pushServerId: String) -> Agent? {
        let freshList = loadAgents()
        return freshList.first { agent in
            agent.pushServerId == pushServerId
        }
    }
    
    private func addAgent(_ agent: Agent) {
        var list = self.loadAgents()
        list.append(agent)
        self.saveAgents(list)
    }
    
    func loadAgents() -> [Agent] {
        do {
            guard let storage else {
                print("ERROR: no agent storage set")
                return []
            }
            
            print("Loading agents...")
            if !FileManager.default.fileExists(atPath: storage.path) {
                print("No agents found")
                return []
            }
            
            let data = try Data(contentsOf: storage)
            let decoder = JSONDecoder()
            let freshList = try decoder.decode([Agent].self, from: data)
            DispatchQueue.main.async {
                self.list = freshList
            }
            return freshList
        } catch {
            print("Failed to load agents")
            print(error)
            return []
        }
    }
    
    private func saveAgents(_ newList: [Agent]) {
        do {
            guard let storage else {
                print("ERROR: no agent storage set")
                return
            }
            
            print("Saving agents: \(storage)")
            
            let encoder = JSONEncoder()
            
            let data = try encoder.encode(newList)
            
            try data.write(to: storage)
            
            DispatchQueue.main.async {
                self.list = newList
            }
        } catch {
            print(error)
        }
    }
    
    func deleteAgent(_ agent: Agent) async throws {
        guard let url = URL(string: "\(PUSH_SERVER_URL)/revoke?id=\(agent.pushServerId)") else {
            print("Invalid url")
            return
        }
        
        print("Deleting agent \(agent.id)")
        
        print(url)
        
        let (data, _) = try await URLSession.shared.data(from: url) //TODo pass token in request
        
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        // Handle the raw JSON response (json variable)
        print("Raw JSON response from push server: \(json)")
        
        //TODO unregister with the push server
        
        //TODO handle persist operations on background thread
        DispatchQueue.main.async {
            var freshList = self.loadAgents()
            freshList.removeAll { $0.id == agent.id }
            self.saveAgents(freshList)
        }
    }
    
    @Published var list: [Agent] = []
}
