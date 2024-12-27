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
                Text("It can be difficult to find inspiration! Here are some ideas to think about as you get started:")
                    .font(.body)
                    .fontWidth(.expanded)
                
                ForEach(generalPrompts, id: \.self) { prompt in
                    PromptView(prompt: prompt)
                }
                
                Divider()
                Text("It's also helpful to think about the intention you selected:")
                    .font(.body)
                    .fontWidth(.expanded)
                ForEach(selectedIntention.prompts, id: \.self) { prompt in
                    PromptView(prompt: prompt)
                        .font(.body)
                        .fontWidth(.expanded)
                }
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

struct PromptView: View {
    var prompt: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .foregroundStyle(.thinMaterial)
                .shadow(radius: 2, y:3)
            
            RoundedRectangle(cornerRadius: 40)
                .strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
                .blur(radius: 1)
        
            Text(prompt)
                .multilineTextAlignment(.center)
                .font(.body)
                .fontWidth(.expanded)
                .padding()
        }
        .padding(5)
        .rotationEffect(.degrees(Double.random(in: -2...2)))
    }
}
