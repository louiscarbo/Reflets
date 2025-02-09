//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

struct ViewContainer: View {
    @State private var currentView = 0
    
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
            default:
                ARSelfPortraitView(
                    screenNumber: $currentView
                );
            }
        }
    }
}

#Preview {
    ViewContainer()
}
