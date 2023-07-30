//
//  ViewModel.swift
//  SmartSats
//
//  Created by Jason van den Berg on 2023/07/23.
//

import SwiftUI
import Combine

enum OnboardingModal: String {
    case intro1
    case intro2
    case intro3
}

class ViewModel: ObservableObject {
    public static var shared = ViewModel()
    private init() {}
    
    //Onboarding
    @AppStorage("showOnboardingModal")  var showOnboardingModal = true
    @Published var dismissOnboardingModal = false
    @Published var selectedOnboardingModal: OnboardingModal = .intro1
}
