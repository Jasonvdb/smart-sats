//
//  SmartSatsApp.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/06.
//

import SwiftUI

@main
struct SmartSatsApp: App {
    @ObservedObject var ln = LN.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            print("***onForeground")
                            try await ln.start()
                        } catch {
                            print("Failed to stop node")
                        }
                    }
                }
            //MARK: TODO figure out why these events get called randomly
//                .onBackground {
//                    Task {
//                        do {
//                            print("***onBackground")
//                            try await ln.stop()
//                        } catch {
//                            print("Failed to stop node")
//                        }
//                    }
//                }
//                .onForeground {
//                    Task {
//                        do {
//                            print("***onForeground")
//                            try await ln.start()
//                        } catch {
//                            print("Failed to stop node")
//                        }
//                    }
//                }
        }
    }
}
