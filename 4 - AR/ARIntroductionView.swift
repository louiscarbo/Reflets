//
//  ARIntroductionView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 07/01/2025.
//

import SwiftUI

struct ARIntroductionView: View {
    // MARK: - Properties
    @Binding var arObjects: [ARObject]
    @Binding var objectScale: Float
    @Binding var showObjectsCatalog: Bool
    @Binding var showCustomizationSheet: Bool
    @Binding var showInspirationSheet: Bool
    
    @State private var scaledObject: Bool = false
    @State var selectedNewType: Bool = false
    @State var customizedObject: Bool = false
    @State var showedInspiration: Bool = false
    @State var completedStates: Set<IntroductionState> = []
    
    enum IntroductionState: CaseIterable {
        case addObject, removeObject, scaleObject, changeTypeObject, customizeObject, inspirationAndFinish, last
    }
    
    @State private var currentState: IntroductionState = .addObject

    // MARK: - Body
    var body: some View {
        ZStack {
            // Display instructions based on the current state
            instructionView(for: currentState)
                .transition(.opacity)
                .animation(.easeInOut, value: currentState)
        }
        .onAppear {
            updateIntroductionState()
        }
        .onChange(of: arObjects.count) {
            updateIntroductionState()
        }
        .onChange(of: objectScale) {
            scaledObject = true
            updateIntroductionState()
        }
        .onChange(of: showObjectsCatalog) { oldValue, newValue in
            if oldValue == true && newValue == false {
                selectedNewType = true
            }
            updateIntroductionState()
        }
        .onChange(of: showCustomizationSheet) { oldValue, newValue in
            if oldValue == true && newValue == false {
                customizedObject = true
            }
            updateIntroductionState()
        }
        .onChange(of: showInspirationSheet) { oldValue, newValue in
            if oldValue == true && newValue == false {
                showedInspiration = true
            }
            updateIntroductionState()
        }
    }
    
    // MARK: - Instruction Views
    @ViewBuilder
    private func instructionView(for state: IntroductionState) -> some View {
        switch state {
        case .addObject:
            TooltipView(
                text: "Let's get started! Tap the + button to add your first object.",
                symbol: Image(systemName: "plus")
            )
        case .removeObject:
            TooltipView(
                text: "Use the undo button to remove the last object.",
                symbol: Image(systemName: "arrowshape.turn.up.backward")
            )
        case .scaleObject:
            TooltipView(
                text: "Use the slider on the left to scale the object.",
                pushToTheRight: true
            )
        case .changeTypeObject:
            TooltipView(
                text: "Explore other object shapes and create custom objects from your photos in the catalog.",
                symbol: Image(systemName: "folder.badge.plus")
            )
        case .customizeObject:
            TooltipView(
                text: "Tap the paintbrush to customize your object.",
                symbol: Image(systemName: "paintbrush")
            )
        case .inspirationAndFinish:
            TooltipView(
                text: "Find inspiration and tips in the Inspiration page.",
                symbol:
                    Image("Reflets")
                    .resizable()
            )
        case .last:
            TooltipView(
                text: "You’re all set! Tap the checkmark when you’re done to finalize your artwork.",
                symbol: Image(systemName: "checkmark"),
                showOKButton: true
            )
        }
    }
    
    // MARK: - State Update Logic
    private func updateIntroductionState() {
        // Avoid repeating states
        if completedStates.contains(currentState) { return }
        
        switch currentState {
        case .addObject:
            if arObjects.count > 0 {
                moveToNextState(.removeObject)
            }
        case .removeObject:
            if arObjects.count == 0 {
                moveToNextState(.scaleObject)
            }
        case .scaleObject:
            if scaledObject {
                moveToNextState(.changeTypeObject)
            }
        case .changeTypeObject:
            if selectedNewType {
                moveToNextState(.customizeObject)
            }
        case .customizeObject:
            if customizedObject {
                moveToNextState(.inspirationAndFinish)
            }
        case .inspirationAndFinish:
            if showedInspiration {
                moveToNextState(.last)
            }
        case .last:
            break
        }
    }

    private func moveToNextState(_ nextState: IntroductionState) {
        withAnimation {
            completedStates.insert(currentState)
            currentState = nextState
        }
    }
}

// MARK: - Tooltip View
struct TooltipView: View {
    let text: String
    var symbol: Image? = nil
    var showOKButton: Bool = false
    var pushToTheRight: Bool = false
    
    @State var showIntroduction = true
    
    var body: some View {
        if showIntroduction {
            HStack {
                if pushToTheRight {
                    Spacer()
                        .frame(width: 50)
                }
                VStack {
                    Text(text)
                        .padding(20)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .fontWidth(Font.Width(0.05))
                        .foregroundStyle(.white)
                    
                    if let symbol = symbol {
                        Button { } label: {
                            symbol
                                .resizable()
                                .scaledToFit()
                                .frame(height: 31)
                        }
                        .buttonStyle(SFSymbolButtonStyle(symbolSize: 30))
                        .padding(.bottom, 20)
                        .opacity(0.7)
                        .allowsHitTesting(false)
                    }
                    
                    if showOKButton {
                        Button("Start creating") {
                            withAnimation {
                                showIntroduction = false
                            }
                        }
                        .buttonStyle(TitleButton())
                        .padding(.bottom, 20)
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.ultraThinMaterial.opacity(1.0))
                        .blur(radius: 5)
                        .allowsHitTesting(false)
                }
                .padding(20)
            }
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
            screenNumber: .constant(5),
            selectedIntention: Intentions.proud.details)
    }
}
