//
//  ArtworkValidationView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 06/01/2025.
//

import SwiftUI

struct ArtworkValidationView: View {
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
    ArtworkValidationView(
        artworkIsDone: .constant(true)
    )
}

struct Step1: View {
    @Binding var artworkIsDone: Bool
    @Binding var validationStep: Int
    
    var body: some View {
        VStack {
            Text("Are you happy with your self portrait?")
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
            Text("Wow, look at that! You've created something so uniquely you! Your intention really shines through! \n\n What would you like to name your artwork?")
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
        "Amazing work! Taking the time to create a self-portrait like this isn’t just creative—it’s a powerful way to explore who you are. Reflection helps you build self-awareness, spark creativity, and grow in ways you might not even realize yet.",
        "Why not make introspection a regular practice? Try journaling, revisit this experience with a new intention, or even share your artwork with someone and ask for their perspective. Each step brings you closer to understanding yourself.",
        "Keep creating, keep reflecting, and keep discovering—you’re doing something truly meaningful!\n\nThank you for creating with Reflets. We can’t wait to see what you make next!"
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
