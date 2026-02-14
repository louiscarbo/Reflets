//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

struct ViewContainer: View {
    @AppStorage("hasSeenIntroduction") var hasSeenIntroduction: Bool = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        if !hasSeenIntroduction {
             IntroductionViewShim(hasSeenIntroduction: $hasSeenIntroduction)
        } else {
            NavigationStack(path: $navigationPath) {
                HomeView()
            }
        }
    }
}

// Temporary Shim to adapt the old IntroductionView
struct IntroductionViewShim: View {
    @Binding var hasSeenIntroduction: Bool
    @State private var screenNumber = 0 // Dummy
    
    var body: some View {
        IntroductionView(screenNumber: $screenNumber)
            .onChange(of: screenNumber) {
                if screenNumber > 0 {
                    hasSeenIntroduction = true
                }
            }
    }
}

#Preview {
    ViewContainer()
}
