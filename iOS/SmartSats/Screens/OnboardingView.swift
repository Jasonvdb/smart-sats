//
//  OnboardingView.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/26.
//

import SwiftUI
import AVKit

struct OnboardingView: View {
    @State var appear = false
    @State var appearBackground = false
    @State var viewState = CGSize.zero
    
    @ObservedObject var viewModel = ViewModel.shared
    
    @State var player = AVPlayer()
    
    private let publisher = NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                viewState = value.translation
            }
            .onEnded { value in
                if value.translation.height > 10300 { //TODO change to 300 to dismiss again
                    dismissModal()
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        viewState = .zero
                    }
                }
            }
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(appear ? 1 : 0)
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                Group {
                    switch viewModel.selectedOnboardingModal {
                    case .intro1:
                        OnboardingContent(
                            title: "Welcome to SmartSats!",
                            text: "A noncustodial, convenient, and private way to pay for your AI agents. \n\nMaintain full control of their spending with pre-authorized assigned budgets.",
                            bottomText: nil,
                            buttonTitle: "Get started"
                        ) {
                            viewModel.selectedOnboardingModal = .intro2
                        }
                    case .intro2:
                        OnboardingContent(
                            title: "How it works",
                            text: "This wallet uses BreezSDK/Greenlight.\n\nNode runs in the cloud but all keys are stored locally.\n\nSmartSats allows AI agents to deduct funds as and when needed, but within your pre-defined budget.",
                            bottomText: nil,
                            buttonTitle: "OK"
                        ) {
                            viewModel.selectedOnboardingModal = .intro3
                        }
                    case .intro3:
                        OnboardingContent(
                            title: "Demo Wallet",
                            text: "The sats are real but to make initial testing and feedback easier this wallet comes with a pre generated seed which is why you will see existing transactions.\n\nPlease don't send any funds to this wallet you don't mind donating.\n",
                            bottomText: nil,
                            buttonTitle: "I promise I won't"
                        ) {
                            dismissModal()
                        }
                    }
                }
                .rotationEffect(.degrees(viewState.width / 100))
                .rotation3DEffect(.degrees(viewState.height / 100), axis: (x: 1, y: 0, z: 0), perspective: 1)
                .shadow(color: Color("Shadow").opacity(0.2), radius: 30, x: 0, y: 30)
                .offset(x: viewState.width / 8, y: viewState.height / 8)
                .gesture(drag)
                .frame(maxHeight: .infinity, alignment: .center)
                .offset(y: appear ? 0 : proxy.size.height)
                .background(
                    Image("Blob 1")
                        .opacity(0.5)
                        .offset(x: 140, y: -100)
                        .opacity(appearBackground ? 1 : 0)
                        .offset(y: appearBackground ? -10 : 0)
                        .blur(radius: appearBackground ? 0 : 40)
                        .hueRotation(.degrees(viewState.width / 20))
                        .allowsHitTesting(false)
                        .accessibility(hidden: true)
                )
                .background(
                    VideoPlayer(player: player)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.screenWidth * 2, height: UIScreen.screenHeight * 2)
                        .background(Color.brandAccent2.opacity(0.8))
                        .blur(radius: appearBackground ? 0 : 40)
                        .hueRotation(.degrees(viewState.width / 20))
                        .allowsHitTesting(false)
                        .accessibility(hidden: true)
                        .opacity(0.2)
                        .ignoresSafeArea()
                        .onAppear {
                            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
                            let videoURL = Bundle.main.url(forResource: "lightning-clip", withExtension: "mp4")!
                            player = AVPlayer(url: videoURL)
                            player.audiovisualBackgroundPlaybackPolicy = .pauses
                            player.rate = 0.0015
                            player.play()
                        }
                        .onReceive(publisher) { _ in
                            player.seek(to: .zero)
                            player.play()
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.horizontal)
            .ignoresSafeArea()
            .offset(y: appear ? 0 : -100)
        }
        .onAppear {
            withAnimation(.spring()) {
                appear = true
            }
            withAnimation(.easeOut(duration: 2)) {
                appearBackground = true
            }
        }
        .onDisappear {
            withAnimation(.spring()) {
                appear = false
            }
            withAnimation(.easeOut(duration: 1)) {
                appearBackground = true
            }
        }
        .onChange(of: viewModel.dismissOnboardingModal) { _ in
            dismissModal()
        }
        .accessibilityAddTraits(.isModal)
    }
}

extension OnboardingView {
    func dismissModal() {
        withAnimation {
            appear = false
            appearBackground = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.showOnboardingModal = false
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
