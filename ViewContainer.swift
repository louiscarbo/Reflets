//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

struct ViewContainer: View {
    @State private var currentView = 0
    @State private var rotationAngle = 0.0
    
    var body: some View {
        switch currentView {
        case 0:
            HomeView(screenNumber: $currentView, rotationAngle: $rotationAngle);
        case 1:
            IntroductionView(screenNumber: $currentView, rotationAngle: rotationAngle);
        case 2:
            PhotoBoothView(screenNumber: $currentView);
        case 3:
            SelfiesView(screenNumber: $currentView);
        default:
            ARAutoportraitView(screenNumber: $currentView);
        }
    }
}

#Preview {
    ViewContainer()
}
