//
//  ContentView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/06.
//

import SwiftUI
import BreezSDK

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var ln = LN.shared
    
    var body: some View {
        HomeView()
            .onChange(of: scenePhase) { newPhase in
                Task {
                    do {
                        guard ln.hasNode else {
                            return
                        }
                        
                        if newPhase == .active {
                            try await ln.connect()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
