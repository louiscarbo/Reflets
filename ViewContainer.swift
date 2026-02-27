//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

struct ViewContainer: View {
    @AppStorage("hasSeenIntroduction") var hasSeenIntroduction: Bool = false
    @State private var navigationPath = NavigationPath()
    
    @State private var isTransitioning = false
    @State private var irisRadius: CGFloat = 3000
    
    var body: some View {
        ZStack {
            Group {
                if !hasSeenIntroduction {
                    IntroductionViewShim(onComplete: startTransition)
                        .transition(.identity)
                } else {
                    NavigationStack(path: $navigationPath) {
                        HomeView()
                    }
                    .transition(.identity)
                }
            }
            .zIndex(0)
            
            if isTransitioning {
                IrisShape(radius: irisRadius)
                    .fill(Color.black, style: FillStyle(eoFill: true))
                    .ignoresSafeArea()
                    .zIndex(1)
                    .allowsHitTesting(true)
            }
        }
    }
    
    private func startTransition() {
        // 1. Add the shape fully open
        irisRadius = 3000
        isTransitioning = true
        
        // 2. Wait a tiny bit for it to render, then close it
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            withAnimation(.bouncy(duration: 3.0)) {
                irisRadius = 0
            }
            
            // 3. Switch view silently while screen is black
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                hasSeenIntroduction = true
                
                // 4. Open the iris to reveal HomeView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.bouncy(duration: 3.0)) {
                        irisRadius = 3000
                    }
                    
                    // 5. Cleanup
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        isTransitioning = false
                    }
                }
            }
        }
    }
}

// Temporary Shim to adapt the old IntroductionView
struct IntroductionViewShim: View {
    var onComplete: () -> Void
    @State private var screenNumber = 0 // Dummy
    
    var body: some View {
        IntroductionView(screenNumber: $screenNumber)
            .onChange(of: screenNumber) {
                if screenNumber > 0 {
                    onComplete()
                }
            }
    }
}

struct IrisShape: Shape {
    var radius: CGFloat
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        let safeRadius = max(0, radius)
        path.addEllipse(in: CGRect(x: rect.midX - safeRadius, y: rect.midY - safeRadius, width: safeRadius * 2, height: safeRadius * 2))
        return path
    }
}

#Preview {
    ViewContainer()
}
