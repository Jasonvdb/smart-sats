//
//  FloatingButton.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/24.
//

import SwiftUI

struct FloatingButton: View {
    let systemName: String

    private let size: CGFloat = 55

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.brandAccent1.opacity(0.5))
                .blur(radius: 10)
                .frame(width: size)
            Circle()
                .fill(Color.brandAccent1.opacity(0.8))
                .frame(width: size)
            Circle()
                .fill(.clear)
                .frame(width: size)
                .overlay {
                    Image(systemName: systemName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.white)
                        .glow(
                            color1: Color.white,
                            color2: Color.white,
                            color3: Color.white,
                            intensity: 0.1,
                            radiusAmplifier: 0.1
                        )
                        .frame(width: 25, height: 25)
                }
                .modifier(CircleOutlineOverlay())
        }
        .padding()
    }
}

struct FloatingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            FloatingButton(systemName: "qrcode.viewfinder")
            FloatingButton(systemName: "hourglass").preferredColorScheme(.dark)
        }
    }
}
