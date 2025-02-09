//
//  InspirationSheetView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 27/12/2024.
//

import SwiftUI

struct InspirationSheetView: View {
    
    // MARK: - InspirationSheetView
    var body: some View {
        ScrollView {
            VStack {
                Text("Inspiration")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                Text("Intention title here")
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

                ForEach(["Prompt1", "Prompt2", "Prompt3"], id: \.self) { prompt in
                    PromptView(prompt: prompt)
                }
                
                // Specific Intention --------------------------------
                Divider()
                Text("Your Intention")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                ForEach(["Prompt1", "Prompt2", "Prompt3"], id: \.self) { prompt in
                    PromptView(prompt: prompt)
                }
                
                // Challenges -------------------------------------
                Divider()
                Text("Challenges")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                PromptView(title: "Challenge title here", prompt: "Challenge content goes here")
                    .id("Challenge title here")
                    .transition(.slide.combined(with: .scale))
                Button {
                    
                } label: {
                    Label("New Challenge", systemImage: "shuffle")
                }
                .buttonStyle(IntentionButton())
                .offset(x:10, y: -20)
                .rotationEffect(.degrees(Double.random(in: -3...3)))
                .shadow(radius: 3, y: 3)
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
            arObjectProperties: .constant(ARObjectProperties())
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
