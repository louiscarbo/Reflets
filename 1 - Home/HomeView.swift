//  Created by Louis Carbo Estaque on 28/11/2023.

import SwiftUI

struct HomeView: View {
    @Binding var screenNumber: Int
    
    @State private var rotationAngle: Double = 0
    @State private var isTouching = false
    @State private var timer: Timer? = nil
    
    let notificationFeedback = UINotificationFeedbackGenerator()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(
                    RadialGradient(
                        colors: colorScheme == .light ?
                        [
                            Color(red: 255/255, green: 250/255, blue: 250/255),
                            Color(red: 255/255, green: 220/255, blue: 180/255),
                        ] : [
                            Color(red: 0/255, green: 5/255, blue: 5/255),
                            Color(red: 60/255, green: 30/255, blue: 40/255),
                        ],
                        center: .center,
                        startRadius: 0, endRadius: 500
                    )
                )
            
            VStack(spacing: 0) {
                Image("Reflets")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 170)
                    .rotationEffect(.degrees(rotationAngle))
                    .onAppear {
                        notificationFeedback.prepare()
                        withAnimation(
                            Animation.linear(duration: 20.0)
                                .repeatForever(autoreverses: false)
                        ) {
                            rotationAngle = 360
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0) // Detect touch and movement
                            .onChanged { _ in
                                if !isTouching {
                                    startHapticFeedback()
                                    withAnimation(.bouncy(duration: 10)) {
                                        isTouching = true
                                    }
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.bouncy) {
                                    isTouching = false
                                }
                                stopHapticFeedback()
                            }
                    )
                    .scaleEffect(isTouching ? 3 : 1.0)
                    .zIndex(10)
                
                Text("Reflets")
                    .font(.system(size: 70))
                    .fontWeight(.light)
                    .fontWidth(.expanded)
                
                Text("Your AR self-portrait")
                    .font(.title2)
                    .fontWeight(.light)
                    .fontWidth(.expanded)
                    .padding(.bottom, 20)
                
                Button("Start the experience") {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        screenNumber+=1
                    }
                    notificationFeedback.notificationOccurred(.success)
                }
                .buttonStyle(TitleButton())
                .buttonBorderShape(.capsule)
                .fontWeight(.medium)
                .fontWidth(.expanded)
                
                Button("Skip to camera") {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        screenNumber = 3
                    }
                    notificationFeedback.notificationOccurred(.success)
                }
                .buttonStyle(TitleButton())
                .buttonBorderShape(.capsule)
                .fontWeight(.medium)
                .fontWidth(.expanded)
                .padding()
            }
        }
        .onAppear {
            deleteAllSegmentedPNGs()
        }
    }
    
    // Start repeating haptic feedback
    func startHapticFeedback() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            notificationFeedback.notificationOccurred(.success)
        }
    }

    // Stop repeating the haptic feedback
    func stopHapticFeedback() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    HomeView(screenNumber: .constant(0))
}
