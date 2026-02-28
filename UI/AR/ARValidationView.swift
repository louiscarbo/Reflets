//
//  ARValidationView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 06/01/2025.
//

import SwiftUI
import SwiftData

struct ARValidationView: View {
    @Bindable var board: VisionBoard
    @Binding var artworkIsDone: Bool
    @State var darkenBackground = true
    
    @State private var validationStep = 0
    
    var body: some View {
        ZStack {
            if darkenBackground {
                Rectangle()
                    .foregroundColor(.black.opacity(0.4))
                    .ignoresSafeArea()
            }
            switch validationStep {
            case 0:
                Step1(
                    artworkIsDone: $artworkIsDone,
                    validationStep: $validationStep
                )
            case 1:
                Step2(
                    validationStep: $validationStep,
                    artworkTitle: $board.name
                )
            case 2:
                Step3(
                    validationStep: $validationStep,
                    darkenBackground: $darkenBackground,
                    artworkTitle: board.name
                )
            default:
                Step4(darkenBackground: $darkenBackground)
            }
        }
    }
}

#Preview {
    let board = VisionBoard()
    board.name = "My Dream"
    return ARValidationView(
        board: board,
        artworkIsDone: .constant(true)
    )
}

struct Step1: View {
    @Binding var artworkIsDone: Bool
    @Binding var validationStep: Int
    
    var body: some View {
        VStack {
            Text("Does this vision feel right?")
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
            HStack {
                Button {
                    withAnimation {
                        artworkIsDone = false
                    }
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(SFSymbolButtonStyle(rotateInTrigonometricDirection: true))
                .padding(.trailing, 20)
                Button {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        validationStep += 1
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(SFSymbolButtonStyle())
            }
            .offset(y: -40)
        }
    }
}

struct Step2: View {
    @Binding var validationStep: Int
    @Binding var artworkTitle: String
    
    var body: some View {
        VStack {
            Text("Every object you placed is a piece of you.\n\nWhat would you call this vision board?")
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
            
            TextField("My vision board...", text: $artworkTitle)
                .textFieldStyle(IntentionTextFieldStyle())
                .padding(.horizontal, 40)
            
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        validationStep -= 1
                    }
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward")
                }
                .buttonStyle(SFSymbolButtonStyle(rotateInTrigonometricDirection: true))
                .padding(.trailing, 20)
                
                Button {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        validationStep += 1
                    }
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(SFSymbolButtonStyle())
                .disabled(artworkTitle.isEmpty)
            }
            .offset(y: -15)
        }
    }
}

struct Step3: View {
    @Binding var validationStep: Int
    @Binding var darkenBackground: Bool
    var artworkTitle: String
    
    var body: some View {
        VStack {
            if darkenBackground {
                Text(
                    "It now lives in your world.\n\nWalk around it. Look at it from every angle. Screenshot or record it — and come back to it when you need a reminder of what you're working towards."
                )
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
            } else {
                Button(artworkTitle) {
                    
                }
                .buttonStyle(TitleButton())
                .disabled(true)
                Spacer()
            }
            
            Button("Continue") {
                if !darkenBackground {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        darkenBackground = true
                        validationStep += 1
                    }
                } else {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        darkenBackground = false
                    }
                }
            }
            .buttonStyle(IntentionButton())
        }
    }
}

struct Step4: View {
    let texts = [
        "This is your reflection, built from everything that matters to you right now.",
        "Vision boards work because they make your mind commit to what it wants. You just did that!",
        "Come back to it. In six months, it will mean something different."
    ]
    @State var textIndex = 0
    @Binding var darkenBackground: Bool
    
    var body: some View {
        VStack {
            if darkenBackground {
                Text(texts[textIndex])
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
            } else {
                Spacer()
            }
            if textIndex != 2 {
                Button("Continue") {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        textIndex += 1
                    }
                }
                .buttonStyle(IntentionButton())
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        darkenBackground.toggle()
                    }
                } label: {
                    Label(darkenBackground ? "Show vision board" : "Hide vision board", systemImage: darkenBackground ? "eye" : "eye.slash")
                }
                .buttonStyle(IntentionButton())
            }
        }
    }
}
