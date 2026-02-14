//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

struct SizeSliderView: View {
    @Binding var sliderValue: Float // From 0 to 1
    @State private var dragOffset: CGFloat = 0 // Offset for the handle
    @State private var sliderHeight: CGFloat = 200 // Height of the slider
    @State private var hasReachedEdge: Bool = false // To block repetitive haptic feedback
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    @State private var initialDragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Slider Track
                VStack {
                    Spacer()
                        .frame(height: 130)
                    Capsule()
                        .frame(width: 15, height: sliderHeight)
                        .glassEffect(.clear)
                    Spacer()
                        .frame(height: 130)
                }
                
                // Slider Handle
                ZStack {
                    Circle()
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 5.0)
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 0.5),
                                    Color(red: 0/255, green: 0/255, blue: 0/255, opacity: 0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 7
                        )
                        .opacity(1.0)
                        .blur(radius: 2)
                        .clipShape(Circle())
                }
                .frame(width: 30, height: 30)
                .offset(y: dragOffset) // Position the handle
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let sliderTop = -sliderHeight / 2
                            let sliderBottom = sliderHeight / 2
                            
                            // Calculate the new drag offset relative to the initial offset
                            let newOffset = initialDragOffset + value.translation.height
                            dragOffset = max(sliderTop, min(sliderBottom, newOffset))
                            
                            // Update the slider value based on the offset
                            sliderValue = Float(1 - (dragOffset + sliderHeight / 2) / sliderHeight)
                            
                            // Trigger haptic feedback at edges (once per edge)
                            if (sliderValue == 0 || sliderValue == 1), !hasReachedEdge {
                                hapticFeedback.impactOccurred()
                                hasReachedEdge = true
                            } else if sliderValue > 0 && sliderValue < 1 {
                                hasReachedEdge = false
                            }
                        }
                        .onEnded { _ in
                            hasReachedEdge = false // Reset edge detection
                            initialDragOffset = dragOffset // Store the final offset for the next drag
                        }
                )
            }
            .onAppear {
                // Set initial drag offset based on sliderValue
                dragOffset = CGFloat(CGFloat(1 - sliderValue) * sliderHeight - sliderHeight / 2)
                sliderHeight = geometry.size.height - 260 // Dynamically adjust height
            }
        }
        .frame(width: 50) // Width of the slider
    }
}

#Preview {
    ZStack {
        GeometryReader { geometry in
            Image("previewImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        ARVisionBoardView(board: VisionBoard())
    }
}
