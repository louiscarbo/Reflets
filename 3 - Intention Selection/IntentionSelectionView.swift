//  Created by Louis Carbo Estaque on 28/11/2023.

import SwiftUI

struct IntentionSelectionView: View {
    @Binding var screenNumber: Int
    
    @State private var rotationAngle: Double = 0
    @State private var dialogueNumber = 0
    @State private var textOpacity = 0.0
    @State private var visibleButtons = 0
    
    @State private var floatingOffsets: [Int: CGSize] = [:]
    @State private var floatingRotations: [Int: Double] = [:]
    
    var selectedIntention: String = ""
    @State private var focusedButtonIndex: Int? = nil
    @State private var buttonPositions: [Int: CGRect] = [:]
    
    let intentions = Intentions.allCases.map { $0.details.title }
    let comments = Intentions.allCases.map { $0.details.comment}
    
    //MARK: View
    var body: some View {
        ZStack {
            // Background layer dims when a button is focused
            Color.black
                .opacity(focusedButtonIndex == nil ? 0.0 : 0.6)
                .animation(.easeInOut, value: focusedButtonIndex)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        focusedButtonIndex = nil
                    }
                }
            
            // Buttons when focused
            if focusedButtonIndex != nil {
                HStack {
                    Button {
                        withAnimation {
                            self.focusedButtonIndex = nil
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
            
            if let focusedButtonIndex = focusedButtonIndex {
                Text(comments[focusedButtonIndex])
                    .padding(40)
                    .multilineTextAlignment(.center)
                    .font(.title2)
                    .fontDesign(.serif)
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
                        .font(.system(.largeTitle))
                        .foregroundStyle(.black)
                        .fontDesign(.serif)
                        .shadow(color: Color.white.opacity(0.2), radius: 10, x: 0, y: 0)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)

                // Buttons
                VStack {
                    ForEach(intentions.indices, id: \.self) { index in
                        let isFocused = focusedButtonIndex == index

                        if index < visibleButtons {
                            IntentionButtonView(
                                index: index,
                                floatingOffsets: $floatingOffsets,
                                floatingRotations: $floatingRotations,
                                text: intentions[index],
                                focusedButtonIndex: $focusedButtonIndex
                            )
                            .background(
                                GeometryReader { geometry in
                                    Color.clear
                                        .onAppear {
                                            buttonPositions[index] = geometry.frame(in: .global)
                                        }
                                        .onChange(of: geometry.frame(in: .global)) {
                                            buttonPositions[index] = geometry.frame(in: .global)
                                        }
                                }
                            )
                            .offset(x: isFocused ? centerOffset(for: index).width : 0,
                                    y: isFocused ? centerOffset(for: index).height : 0)
                        }
                    }
                }
                .onAppear {
                    animateButtons()
                }
            }
        }
        .background {
            Image("Reflets")
                .resizable()
                .frame(width: 700, height: 700)
                .rotationEffect(Angle(degrees: rotationAngle))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 120.0)
                            .repeatForever(autoreverses: false)
                    ) { rotationAngle = 360 }
                }
        }
    }
    
    private func animateButtons() {
        for index in intentions.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.9) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    visibleButtons += 1
                }
            }
        }
    }
    
    private func centerOffset(for index: Int) -> CGSize {
        guard let buttonFrame = buttonPositions[index] else { return .zero }
        let screenCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
        let buttonCenter = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)

        return CGSize(
            width: screenCenter.x - buttonCenter.x,
            height: screenCenter.y - buttonCenter.y
        )
    }
}

#Preview {
    IntentionSelectionView(screenNumber: .constant(2))
}

// MARK: Subviews
private struct IntentionButtonView: View {
    var index: Int
    @Binding var floatingOffsets: [Int: CGSize]
    @Binding var floatingRotations: [Int: Double]
    var text: String
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    @Binding var focusedButtonIndex: Int?
    
    var body: some View {
        let isFocused = focusedButtonIndex == index
        let rotation = floatingRotations[index] ?? Double.random(in: -2...2)
        let xOffset = floatingOffsets[index]?.width ?? CGFloat.random(in: -10...10)
        
        Button(text) {
            hapticFeedback.notificationOccurred(.success)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                focusedButtonIndex = isFocused ? nil : index
            }
        }
        .buttonStyle(IntentionButton())
        .rotationEffect(.degrees(rotation))
        .offset(x: isFocused ? 0 : xOffset, y: 0)
        .padding(.vertical, 3)
        .scaleEffect(isFocused ? 1.5 : 1.0)
        .zIndex(isFocused ? 1 : 0)
        .opacity(focusedButtonIndex == nil || isFocused ? 1.0 : 0.5)
        .onAppear {
            startFloatingEffect(for: index)
        }
    }
    
    private func startFloatingEffect(for index: Int) {
        withAnimation(
            Animation.easeInOut(duration: Double.random(in: 2.0...4.0))
                .repeatForever(autoreverses: true)
        ) {
            floatingOffsets[index] = CGSize(
                width: CGFloat.random(in: -10...10),
                height: 0
            )
            floatingRotations[index] = Double.random(in: -5...5)
        }
    }
}
