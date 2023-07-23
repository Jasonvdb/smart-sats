//
//  Agents.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import Foundation

struct Agent: Hashable {
    let name: String
    let description: String
}

class Agents: ObservableObject {
    public static var shared = Agents()
    
    private init() {}
    
    @Published var list: [Agent] = [
        .init(name: "Agent 1", description: "Does web design"),
        .init(name: "Agent 2", description: "Does logo design")
    ]
}
