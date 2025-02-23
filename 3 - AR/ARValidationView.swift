//
//  ARValidationView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 06/01/2025.
//

import SwiftUI

struct ARValidationView: View {
    @Binding var artworkIsDone: Bool
    @State var artworkTitle = ""
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
                    artworkTitle: $artworkTitle
                )
            case 2:
                Step3(
                    validationStep: $validationStep,
                    darkenBackground: $darkenBackground,
                    artworkTitle: artworkTitle
                )
            default:
                Step4(darkenBackground: $darkenBackground)
            }
        }
    }
}

#Preview {
    ARValidationView(
        artworkIsDone: .constant(true)
    )
}

struct Step1: View {
    @Binding var artworkIsDone: Bool
    @Binding var validationStep: Int
    
    var body: some View {
        VStack {
            Text("Are you happy with your vision board?")
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
            Text("Wow, look at that! You've created something really unique that really represents your vision! Now, what would you like to name your vision board?")
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
            
            TextField("Name your artwork", text: $artworkTitle)
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
                    "What a meaningful title! It perfectly captures the essence of your artwork.\n\nTake some time to appreciate your work. Feel free to snap a screenshot or record a video to look back on whenever you want !"
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
        "Amazing work! You’ve just built a vision board filled with your ideas, dreams, and inspirations. Taking the time to visualize what excites you is a powerful way to bring those aspirations to life.",
        "Why stop here? Let this be a starting point—use your vision board as a reminder of what excites you, revisit it with fresh ideas, or even share it with someone who inspires you. Creativity and imagination fuel action, and every small step brings you closer to what you want.",
        "Keep dreaming, keep building, and keep exploring—your ideas deserve space to grow!\n\nThank you for creating with Reflets. We can’t wait to see what you bring to life next!"
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
                    Label(darkenBackground ? "Show artwork" : "Hide artwork", systemImage: darkenBackground ? "eye" : "eye.slash")
                }
                .buttonStyle(IntentionButton())
            }
        }
    }
}
