//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI

struct ARControlsView: View {
    @Binding var showReflectoHelp: Bool
    
    @Binding var showObjectsCatalog: Bool
    
    @Binding var artworkIsDone: Bool
    
    @Binding var shouldAddObject: Bool
    @State private var addObjectsTimer: Timer? = nil
    @State private var removeObjectsTimer: Timer? = nil
    
    @Binding var showCustomizationSheet: Bool
    
    @Binding var arObjects: [ARObject]

    @Binding var sliderValue: Double
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                HStack(spacing: 10) {
                    Button {
                        withAnimation {
                            showReflectoHelp = true
                        }
                    } label: {
                        Image("Reflets")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 31)
                    }
                    .buttonStyle(SFSymbolButtonStyle(symbolSize: 16))
                    Button {
                        withAnimation {
                            showObjectsCatalog = true
                        }
                    } label: {
                        Image(systemName: "folder.badge.plus")
                    }
                    .buttonStyle(SFSymbolButtonStyle(symbolSize: 20))
                    Button {
                        withAnimation {
                            artworkIsDone = true
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(SFSymbolButtonStyle(symbolSize: 20))
                }
                .padding(.horizontal, 30)
                .padding(.vertical)
                .background {
                    ZStack {
                        Capsule()
                            .foregroundStyle(.thinMaterial.opacity(0.7))
                            .shadow(radius: 10)
                        
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.black.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing),
                                lineWidth: 15)
                            .blur(radius: 4)
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        if !arObjects.isEmpty {
                            arObjects.removeLast()
                        }
                        if removeObjectsTimer != nil {
                            removeObjectsTimer?.invalidate()
                            removeObjectsTimer = nil
                        }
                        hapticFeedback.notificationOccurred(.success)
                    } label: {
                        Image(systemName: "arrowshape.turn.up.backward")
                    }
                    .buttonStyle(SFSymbolButtonStyle(rotateInTrigonometricDirection: true))
                    .disabled(arObjects.isEmpty)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.2)
                            .onEnded { _ in
                                removeObjectsTimer?.invalidate()
                                removeObjectsTimer = nil
                            }
                    )
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0) // Detects continuous press while dragging slightly
                            .onChanged { _ in
                                if !arObjects.isEmpty {
                                    if removeObjectsTimer == nil {
                                        removeObjectsTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                                            if !arObjects.isEmpty {
                                                arObjects.removeLast()
                                            }
                                            hapticFeedback.notificationOccurred(.success)
                                        }
                                    }
                                }
                            }
                    )
                    
                    Button {
                        withAnimation {
                            shouldAddObject = true
                        }
                        if addObjectsTimer != nil {
                            addObjectsTimer?.invalidate()
                            addObjectsTimer = nil
                        }
                        hapticFeedback.notificationOccurred(.success)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(SFSymbolButtonStyle(symbolSize: 45))
                    .gesture(
                        LongPressGesture(minimumDuration: 0.2)
                            .onEnded { _ in
                                addObjectsTimer?.invalidate()
                                addObjectsTimer = nil
                            }
                    )
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0) // Detects continuous press while dragging slightly
                            .onChanged { _ in
                                if addObjectsTimer == nil {
                                    addObjectsTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                                        withAnimation {
                                            shouldAddObject = true
                                        }
                                        hapticFeedback.notificationOccurred(.success)
                                    }
                                }
                            }
                    )
                    
                    Button {
                        withAnimation {
                            showCustomizationSheet = true
                        }
                    } label: {
                        Image(systemName: "paintbrush")
                    }
                    .buttonStyle(SFSymbolButtonStyle())
                }
                .padding(.horizontal, 30)
                .padding(.vertical)
                .background {
                    ZStack {
                        Capsule()
                            .foregroundStyle(.thinMaterial.opacity(0.7))
                            .shadow(radius: 10)
                        
                        Capsule()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.black.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing),
                                lineWidth: 15)
                            .blur(radius: 4)
                            .clipShape(Capsule())
                    }
                }
            } // VStack
            
            SizeSliderView(sliderValue: $sliderValue)
                .offset(y: -30)
        }
    }
}

#Preview {
    @Previewable @State var value = 0.0
    
    ZStack {
        Image("previewImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ARControlsView(
            showReflectoHelp: .constant(false),
            showObjectsCatalog: .constant(false),
            artworkIsDone: .constant(false),
            shouldAddObject: .constant(false),
            showCustomizationSheet: .constant(false),
            arObjects: .constant([]),
            sliderValue: $value
        )
        Text("\(value)")
            .font(.largeTitle)
    }
}

import SwiftUI

struct SizeSliderView: View {
    @Binding var sliderValue: Double // From 0 to 1
    @State private var dragOffset: CGFloat = 0 // Offset for the handle
    @State private var sliderHeight: CGFloat = 300 // Height of the slider
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
                        .foregroundStyle(.thinMaterial.opacity(0.7))
                        .shadow(radius: 10)
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
                            sliderValue = Double(1 - (dragOffset + sliderHeight / 2) / sliderHeight)

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
                dragOffset = CGFloat((1 - sliderValue) * sliderHeight - sliderHeight / 2)
                sliderHeight = geometry.size.height - 260 // Dynamically adjust height
            }
        }
        .frame(width: 50) // Width of the slider
    }
}
