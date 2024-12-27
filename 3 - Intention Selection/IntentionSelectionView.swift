//  Created by Louis Carbo Estaque on 28/11/2023.

import SwiftUI

struct IntentionSelectionView: View {
    // App navigation variables
    @Binding var screenNumber: Int
    
    // Animation
    @State private var rotationAngle: Double = 0
    
    // Buttons positioning
    @State private var buttonPositions: [Intention: CGRect] = [:]
    
    // Intention selection
    @State private var visibleIntentions: [Intention] = []
    let intentions = Intentions.allCases.map { $0.details }
    @Binding var selectedIntention: Intention?
    
    //MARK: View
    var body: some View {
        ZStack {
            // Background layer dims when a button is focused
            Color.black
                .opacity(selectedIntention == nil ? 0.0 : 0.6)
                .animation(.easeInOut, value: selectedIntention)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        selectedIntention = nil
                    }
                }
            
            // Buttons when focused
            if selectedIntention != nil {
                HStack {
                    Button {
                        withAnimation {
                            selectedIntention = nil
                        }
                    } label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    }
                    .buttonStyle(SFSymbolButtonStyle(rotateInTrigonometricDirection: true))
                    Button {
                        withAnimation {
                            screenNumber += 1
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(SFSymbolButtonStyle())
                }
                .transition(.opacity.combined(with: .scale(scale: 0.5, anchor: .bottom)))
                .zIndex(1.0)
                .offset(y: 50)
            }
            
            // Intention comment when focused
            if let selectedIntention = selectedIntention {
                Text(selectedIntention.comment)
                    .padding(40)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontWidth(Font.Width(0.05))
                    .foregroundStyle(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundStyle(.ultraThinMaterial.opacity(1.0))
                            .blur(radius: 5)
                            .padding(20)
                    }
                    .offset(y: 170)
                    .zIndex(1.0)
                    .transition(.opacity.combined(with: .scale(scale: 0.5, anchor: .bottom)))
            }

            // Content layer
            VStack {
                // Title
                HStack {
                    Text("What will your intention be?")
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                        .fontWidth(.expanded)
                        .fontWeight(.semibold)
                        .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 0)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)

                // Buttons
                VStack {
                    ForEach(intentions, id: \.self) { intention in
                        if visibleIntentions.contains(intention) {
                            
                            let isFocused = selectedIntention == intention
                            IntentionButtonView(
                                intention: intention,
                                selectedIntention: $selectedIntention
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            buttonPositions[intention] = geometry.frame(in: .global)
                                        }
                                        .onChange(of: geometry.frame(in: .global)) {
                                            buttonPositions[intention] = geometry.frame(in: .global)
                                        }
                                }
                            )
                            .offset(
                                x: isFocused ? centerOffset(for: intention).width : 0,
                                y: isFocused ? centerOffset(for: intention).height : 0
                            )
                        }
                    }
                }
                .onAppear {
                    animateButtonsAppearance()
                }
            }
        }
        .background {
            Image("Reflets")
                .resizable()
                .frame(width: 700, height: 700)
                .rotationEffect(Angle(degrees: rotationAngle))
                .onAppear {
                    withAnimation(.easeInOut(duration: 120.0).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }
        }
    }
    
    private func animateButtonsAppearance() {
        var index: Int = 0
        for intention in intentions {
            index += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1) * 0.9) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    visibleIntentions.append(intention)
                }
            }
        }
    }
    
    private func centerOffset(for intention: Intention) -> CGSize {
        guard let buttonFrame = buttonPositions[intention] else { return .zero }
        let screenCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        let buttonCenter = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)

        return CGSize(
            width: screenCenter.x - buttonCenter.x,
            height: screenCenter.y - buttonCenter.y
        )
    }
}

#Preview {
    @Previewable @State var intention: Intention? = nil
    
    IntentionSelectionView(
        screenNumber: .constant(2),
        selectedIntention: $intention
    )
}

// MARK: Subviews
private struct IntentionButtonView: View {
    var intention: Intention
    @Binding var selectedIntention: Intention?
    
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        let isFocused = selectedIntention == intention
        
        Button(intention.title) {
            hapticFeedback.notificationOccurred(.success)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                selectedIntention = isFocused ? nil : intention
            }
        }
        .buttonStyle(IntentionButton())
        .rotationEffect(.degrees(rotation))
        .offset(x: isFocused ? 0 : offset.width, y: 0)
        .padding(.vertical, 4)
        .scaleEffect(isFocused ? 1.5 : 1.0)
        .zIndex(isFocused ? 1 : 0)
        .opacity(selectedIntention == nil || isFocused ? 1.0 : 0.5)
        .onAppear {
            startFloatingEffect()
        }
    }
    
    private func startFloatingEffect() {
        withAnimation(
            Animation.easeInOut(duration: Double.random(in: 2.0...4.0))
                .repeatForever(autoreverses: true)
        ) {
            offset = CGSize(
                width: CGFloat.random(in: -10...10),
                height: 0
            )
            rotation = Double.random(in: -5...5)
        }
    }
}
