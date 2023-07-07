//
//  AsyncButton.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/07.
//

import SwiftUI

struct AsyncButton: View {
    var title: String
    var action: () async -> ()
    
    @State private var isPerformingTask = false
    
    var body: some View {
        Button {
            isPerformingTask = true
                        
            Task {
                await action()
                isPerformingTask = false
            }
        } label: {
            let title = isPerformingTask ? AnyView(ProgressView()) : AnyView(Text(title).multilineTextAlignment(.center))
            
            title
                .foregroundColor(.secondary)
                .padding(.vertical, 10)
                .padding(.horizontal, 25)
                .background(.regularMaterial.opacity(0.8))
                .mask(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .opacity(isPerformingTask ? 0.5 : 1)
        .disabled(isPerformingTask)
    }
}

struct AsyncButton_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButton(title: "Tap me") {
            print("Tapped")
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            print("Done")
        }
    }
}
