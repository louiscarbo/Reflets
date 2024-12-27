//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

struct ViewContainer: View {
    @State private var currentView = 0
    @State private var selectedIntention: Intention? = nil
    
    var body: some View {
        ZStack {
            switch currentView {
            case 0:
                HomeView(
                    screenNumber: $currentView
                )
            case 1:
                IntroductionView(
                    screenNumber: $currentView
                );
            case 2:
                IntentionSelectionView(
                    screenNumber: $currentView,
                    selectedIntention: $selectedIntention
                );
            default:
                ARSelfPortraitView(
                    screenNumber: $currentView,
                    selectedIntention: selectedIntention ?? Intentions.other.details
                );
            }
        }
    }
}

#Preview {
    ViewContainer()
}
