//
//  CustomIcon.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI

struct CustomIcon: View {
    let systemName: String
    var accented = false
    var isLoading = false
    
    var size: CGFloat = 26
    
    var body: some View {
        if systemName != "" {
            var image = Image(systemName: systemName)
            
            if accented {
                LinearGradient(
                    gradient: Gradient(colors: [Color.brandAccent1.opacity(0.9), Color.brandAccent2]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .mask {
                    if isLoading {
                        ProgressView().accentColor(Color.brandAccent2)
                    } else {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }
                .frame(width: size, height: size)
                .modifier(CustomIconModifier())
            } else {
                image
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.brandTextSecondary)
                    .frame(width: size, height: size)
                    .modifier(CustomIconModifier())
            }
        }
    }
}

struct CustomIcon_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomIcon(systemName: "bolt.fill")
            CustomIcon(systemName: "bolt.fill", accented: true)
            CustomIcon(systemName: "bolt.fill", accented: true, isLoading: true)
        }
    }
}
