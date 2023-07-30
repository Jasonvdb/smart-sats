//
//  OnboardingContent.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/26.
//

import SwiftUI

struct OnboardingContent: View {
    var title: String
    var text: String
    var bottomText: Text? = nil
    var buttonTitle: String
    var onButtonPress: () -> Void
        
    @State var circleInitialY = CGFloat.zero
    @FocusState var isEmailFocused: Bool
    @FocusState var isPasswordFocused: Bool
    @State var appear = [false, false, false]
    
    @ObservedObject var viewModel = ViewModel.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.largeTitle).bold()
                .foregroundStyle(Color.brandTextPrimary)
                .blendMode(.overlay)
                .slideFadeIn(show: appear[0], offset: 30)
            
            Text(text)
                .font(.headline)
                .foregroundStyle(Color.brandTextSecondary)
                .slideFadeIn(show: appear[1], offset: 20)
            
            content
                .slideFadeIn(show: appear[2], offset: 10)
        }
        .coordinateSpace(name: "stack")
        .padding(20)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .backgroundColor(opacity: 0.4, cornerRadius: 20)
        .cornerRadius(30)
        .modifier(OutlineModifier(cornerRadius: 30))
        .onAppear { animate() }
    }
    
    var content: some View {
        Group {
            CtaButton(
                title: buttonTitle,
                action: {
                    onButtonPress()
                })
            .padding(.top)
            
            if bottomText != nil {
                Divider()
                
                bottomText
                    .font(.footnote)
                    .foregroundColor(Color.brandTextPrimary.opacity(0.7))
                    .accentColor(Color.brandTextPrimary.opacity(0.7))
            }
        }
    }
    
    func animate() {
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.2)) {
            appear[0] = true
        }
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.4)) {
            appear[1] = true
        }
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.6)) {
            appear[2] = true
        }
    }
}

struct OnboardingContent_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContent(
            title: "Test",
            text: "Blah bla bla",
            bottomText: Text("Bottom text"),
            buttonTitle: "Go",
            onButtonPress: {}
        )
    }
}
