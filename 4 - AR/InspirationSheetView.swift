//
//  InspirationSheetView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 27/12/2024.
//

import SwiftUI

struct InspirationSheetView: View {
    @State var selectedIntention: Intention
    
    let generalPrompts: [String] = [
        "Try using AR as a way to tell a story! Which environment would best fit your intention?",
        "Take a look around: what’s in your space that fits your intention? Add an object that interacts with it!",
        "Could it be interesting to add a selfie in the artwork? If so, how can you customize it with objects to make it more impactful?"
    ]
    
    let generalChallenges: [Challenge] = [
        Challenge(
            title: "Abstract You",
            content: "Create a self-portrait using only shapes, colors, and textures. No selfies allowed!"
        ),
        Challenge(
            title: "Environment Fusion",
            content: "Blend your self-portrait with your surroundings. Can you make it feel like it belongs in the space?"
        ),
        Challenge(
            title: "Layer Up",
            content: "Build your self-portrait in layers—start with your environment, then add objects that reflect deeper aspects of yourself."
        ),
        Challenge(
            title: "Perspective Play",
            content: "Use size and distance creatively. Make one part of your self-portrait tiny and another part huge."
        ),
        Challenge(
            title: "Opposite Worlds",
            content: "Create a self-portrait with two contrasting themes—light/dark, calm/chaotic, or old/new. How do they interact?"
        ),
        Challenge(
            title: "Color Story",
            content: "Tell a story with colors. Choose a color palette that represents your personality or mood."
        ),
        Challenge(
            title: "Word Art",
            content: "Add words or phrases that represent you. How can you integrate them into your self-portrait?"
        )
    ]
    
    var allChallenges: [Challenge] {
        generalChallenges + selectedIntention.challenges
    }
    
    @State var currentChallenge: Challenge?
    
    // MARK: - InspirationSheetView
    var body: some View {
        ScrollView {
            VStack {
                Text("Inspiration")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                Text(selectedIntention.title)
                    .italic()
                    .font(.title)
                    .fontWidth(.expanded)
                Divider()
                    .padding(5)
                Text("It can be difficult to find inspiration! Here are some ideas to get you started.")
                    .font(.body)
                    .fontWidth(.expanded)
                
                // General Tips -------------------------------------
                Divider()
                Text("General Tips")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)

                ForEach(generalPrompts, id: \.self) { prompt in
                    PromptView(prompt: prompt)
                }
                
                // Specific Intention --------------------------------
                Divider()
                Text("Your Intention")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                ForEach(selectedIntention.prompts, id: \.self) { prompt in
                    PromptView(prompt: prompt)
                }
                
                // Challenges -------------------------------------
                Divider()
                Text("Challenges")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                if let currentChallenge = currentChallenge {
                    PromptView(title: currentChallenge.title, prompt: currentChallenge.content)
                        .id(currentChallenge)
                        .transition(.slide.combined(with: .scale))
                    Button {
                        withAnimation(.bouncy) {
                            self.currentChallenge = allChallenges.filter { $0 != currentChallenge }.randomElement()
                        }
                    } label: {
                        Label("New Challenge", systemImage: "shuffle")
                    }
                    .buttonStyle(IntentionButton())
                    .offset(x:10, y: -20)
                    .rotationEffect(.degrees(Double.random(in: -3...3)))
                    .shadow(radius: 3, y: 3)
                }
            }
            .onAppear {
                currentChallenge = allChallenges.randomElement()
            }
            .background {
                RandomSymbolsView()
            }
            .padding([.top, .horizontal], 25)
        }
        .presentationBackground(.thinMaterial)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(40.0)
    }
}

#Preview {
    @Previewable @State var isPresented = false;
    
    ZStack {
        Image("previewImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ARControlsView(
            showInspirationSheet: true,
            artworkIsDone: .constant(false),
            arObjects: .constant([]),
            arObjectProperties: .constant(ARObjectProperties()),
            selectedIntention: Intentions.memory.details
        )
    }
}

// MARK: - PromptView
struct PromptView: View {
    var title: String? = nil
    var prompt: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .foregroundStyle(.thinMaterial)
                .shadow(radius: 2, y:3)
            
            RoundedRectangle(cornerRadius: 40)
                .strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
                .blur(radius: 1)
        
            VStack(spacing: 0) {
                if let title = title {
                    Text(title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .fontWidth(.expanded)
                        .padding(.bottom, 5)
                }
                Text(prompt)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .fontWidth(.expanded)
            }
            .padding()
        }
        .rotationEffect(.degrees(Double.random(in: -2...2)))
        .scrollTransition(axis: .vertical) { content, phase in
            content
                .scaleEffect(phase.isIdentity ? 1 : 0.7)
                .opacity(phase.isIdentity ? 1 : 0)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
        .padding(5)
    }
}
