//
//  InspirationSheetView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 27/12/2024.
//

import SwiftUI

struct ChallengesView: View {
    @Binding var selectedChallenge: Challenge?
    
    @Environment(\.dismiss) var dismiss
    
    // MARK: - InspirationSheetView
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Text("Challenges")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                Text("It can be difficult to find inspiration! Here are some challenges to get you started.")
                    .font(.body)
                    .fontWidth(.expanded)
                
                // Challenges -------------------------------------
                Divider()
                    .padding(5)
                
                ForEach(challenges) { challenge in
                    if challenge != selectedChallenge {
                        Button {
                            withAnimation {
                                selectedChallenge = challenge
                            }
                            dismiss()

                        } label: {
                            PromptView(
                                title: challenge.title,
                                prompt: challenge.prompt,
                                sfSymbol: challenge.sfSymbol
                            )
                        }
                    }
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
            arObjectProperties: .constant(ARObjectProperties())
        )
    }
}

// MARK: - PromptView
struct PromptView: View {
    var title: String? = nil
    var prompt: String
    var sfSymbol: String = "questionmark"
    var scrollEffect: Bool = true
    var slimVersion: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: slimVersion ? 30 : 40)
                .foregroundStyle(.thinMaterial)
                .shadow(radius: 2, y:3)
            
            RoundedRectangle(cornerRadius: slimVersion ? 30 : 40)
                .strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
                .blur(radius: 1)
            
            HStack(spacing: 20) {
                if !slimVersion {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .overlay {
                            Image(systemName: sfSymbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(.title)
                                .bold()
                        }
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    if !slimVersion {
                        if let title = title {
                            Text(title)
                                .bold()
                                .font(.body)
                                .fontWidth(.expanded)
                                .padding(.bottom, 5)
                                .lineLimit(2)
                        }
                    }
                    Text(prompt)
                        .font(.body)
                        .fontWidth(slimVersion ? .standard : .expanded)
                        .multilineTextAlignment(.leading)
                }
            }
            .foregroundStyle(.black)
            .padding(slimVersion ? 15 : 20)
        }
        .rotationEffect(.degrees(slimVersion ? 0 : Double.random(in: -2...2)))
        .padding(5)
        .applyScrollEffect(if: scrollEffect) // Custom modifier for clarity
    }
}

extension View {
    @ViewBuilder
    func applyScrollEffect(if enabled: Bool) -> some View {
        if enabled {
            self.scrollTransition(axis: .vertical) { content, phase in
                content
                    .scaleEffect(phase.isIdentity ? 1 : 0.7)
                    .opacity(phase.isIdentity ? 1 : 0)
                    .blur(radius: phase.isIdentity ? 0 : 2)
            }
        } else {
            self // Return the view unchanged when scrollEffect is false
        }
    }
}
