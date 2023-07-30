//
//  CtaButton.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/26.
//

import SwiftUI

struct CtaButton: View {
    var title: String
    var action: () async -> ()
    var onLongPress: (() async ->())? = nil
    
    @State private var isPerformingTask = false
    @GestureState var isDetectingLongPress = false

    var body: some View {
        let title = isPerformingTask ? AnyView(ProgressView()) : AnyView(Text(title).fontWeight(.semibold))
        
        title
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(
                ZStack {
                    angularGradient
                        .opacity(isDetectingLongPress ? 0.95 : 1)
                        .scaleEffect(isDetectingLongPress ? 0.95 : 1)
                    LinearGradient(
                        gradient:
                            Gradient(colors: [
                                Color.brandAccent2.opacity(1),
                                Color.brandAccent2.opacity(0.6)
                            ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .cornerRadius(20)
                    .blendMode(.softLight)
                }
                    .opacity(isPerformingTask ? 0.5 : 1)
                    .modifier(OutlineOverlay())
            )
            .frame(height: 50)
            .accentColor(Color.brandTextPrimary.opacity(0.7))
            .if(onLongPress != nil, transform: { btn in
                btn
                    .scaleEffect(isDetectingLongPress ? 0.995 : 1)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5) //TODO what are the odds someone holds this for a minute?
                            .updating($isDetectingLongPress, body: { currentState, gestureState, transaction in
                                gestureState = currentState
                                transaction.animation = .spring(response: 0.25, dampingFraction: 0.5)
                            })
                            .onEnded({ finished in
                                guard let onLongPress else { return }
                                
                                guard !isPerformingTask else { return }
                                
                                Haptics.play(.rigid)
                                
                                isPerformingTask = true
                                            
                                Task {
                                    await onLongPress()
                                    isPerformingTask = false
                                }
                            })
                    )
            })
                
                .simultaneousGesture(
                    TapGesture().onEnded({ value in
                        guard !isPerformingTask else { return }
                        
                        Haptics.play(.light)
                        
                        isPerformingTask = true
                                    
                        Task {
                            await action()
                            isPerformingTask = false
                        }
                    })
                )
    }
    
    var angularGradient: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.clear)
            .overlay(AngularGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.brandAccent1, location: 0.0),
                    .init(color: Color.brandAccent2, location: 0.4),
                    .init(color: Color.brandAccent1, location: 0.5),
                    .init(color: Color.brandAccent2, location: 0.8)
                ]),
                center: .center
            ))
            .padding(6)
            .blur(radius: 20)
    }
}


struct CtaButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CtaButton(title: "Press Me") {
                print("Tapped")
            }
        }
        .padding()
        .backgroundColor()
    }
}
