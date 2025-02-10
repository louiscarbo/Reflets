//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI

struct ARControlsView: View {
    // Top row buttons
    @State var showInspirationSheet: Bool = false
    @State var showObjectsCatalog: Bool = false
    @Binding var artworkIsDone: Bool
    
    // Bottom row buttons
    @State private var addObjectsTimer: Timer? = nil // Timer for adding button
    @State private var removeObjectsTimer: Timer? = nil // Timer for removing button
    @State var showCustomizationSheet: Bool = false
    
    // AR Objects modification
    @Binding var arObjects: [ARObject]
    @Binding var arObjectProperties: ARObjectProperties
    
    // Challenges
    @State private var selectedChallenge: Challenge? = nil
    @State private var challengesList: [Challenge] = challenges
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    // MARK: - ARControlsView body
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                // MARK: Top row buttons
                HStack(spacing: 10) {
                    Button {
                        withAnimation {
                            showInspirationSheet = true
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
                        withAnimation(.easeInOut(duration: 1.0)) {
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
                
                // MARK: Selected Challenge -------------------------------
                if let challenge = selectedChallenge {
                    Button {
                        selectedChallenge = nil
                    } label: {
                        PromptView(
                            title: challenge.title,
                            prompt: challenge.prompt,
                            sfSymbol: challenge.sfSymbol,
                            scrollEffect: false,
                            slimVersion: true
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .padding(.leading, 50)
                }
                
                Spacer()
                
                // MARK: Bottom row buttons -------------------------------
                HStack(spacing: 20) {
                    
                    // Remove button
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
                    
                    // Add button
                    Button {
                        let newObject = ARObject(
                            properties: arObjectProperties,
                            position: [0, 0, -1]
                        )
                        arObjects.append(newObject)
                        
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
                                            let newObject = ARObject(
                                                properties: arObjectProperties,
                                                position: [0, 0, -1]
                                            )
                                            arObjects.append(newObject)
                                        }
                                        hapticFeedback.notificationOccurred(.success)
                                    }
                                }
                            }
                    )
                    
                    // Customization button
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
            }
            
            // MARK: Slider
            HStack {
                SizeSliderView(sliderValue: $arObjectProperties.resizingFactor)
                    .offset(y: -30)
                Spacer()
            }
            .padding(.leading, 30)
            
            // MARK: ARIntroductionView
            ARIntroductionView(
                arObjects: $arObjects,
                objectScale: $arObjectProperties.resizingFactor,
                showObjectsCatalog: $showObjectsCatalog,
                showCustomizationSheet: $showCustomizationSheet,
                showInspirationSheet: $showInspirationSheet
            )
        }
        .sheet(isPresented: $showCustomizationSheet) {
            ObjectSettingsView(
                needsColor: arObjectProperties.type.hasCustomColor,
                selectedColor: $arObjectProperties.color,
                isMetallic: $arObjectProperties.metallic,
                selectedOpacity: $arObjectProperties.opacity,
                needsText: arObjectProperties.type.hasCustomText,
                textInput:  $arObjectProperties.text,
                needsProportionSlider: arObjectProperties.type.hasCustomRatio,
                selectedProportion: $arObjectProperties.ratio
            )
        }
        .sheet(isPresented: $showObjectsCatalog) {
            ObjectsCatalogSheetView(
                selectedType: $arObjectProperties.type,
                imageURL: $arObjectProperties.imageURL
            )
        }
        .sheet(isPresented: $showInspirationSheet) {
            ChallengesView(
                selectedChallenge: $selectedChallenge,
                challenges: $challengesList
            )
        }
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
        ARSelfPortraitView(
            screenNumber: .constant(5)
        )
    }
}

// MARK: SizeSliderView
struct SizeSliderView: View {
    @Binding var sliderValue: Float // From 0 to 1
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
