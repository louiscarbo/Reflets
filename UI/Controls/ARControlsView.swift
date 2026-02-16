//
//  ARControlsView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI

struct ARControlsView: View {
    @Bindable var session: AREditingSession
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                // MARK: Top Toolbar
                TopRowView()
                
                // MARK: Selected Challenge Display
                ChallengeFloatingView()
                
                Spacer()
                
                // MARK: Object Controls
                BottomRowView()
            }
            
            // MARK: Size Slider
            HStack {
                SizeSliderView(sliderValue: $session.currentObjectProperties.resizingFactor)
                    .offset(y: -30)
                Spacer()
            }
            .padding(.leading, 30)
            
            // MARK: Challenge Detail View
            ChallengeDetailView()
            
            // MARK: Challenge Completion Effect
            ChallengeCompletionView()
            
            // MARK: Introduction
            ARIntroductionView(
                arObjects: $session.board.objects,
                objectScale: $session.currentObjectProperties.resizingFactor,
                showObjectsCatalog: $session.showObjectsCatalog,
                showCustomizationSheet: $session.showCustomizationSheet,
                showInspirationSheet: $session.showInspirationSheet
            )
        }
        .sheet(isPresented: $session.showCustomizationSheet) {
            ObjectSettingsView(
                needsColor: session.currentObjectProperties.type.hasCustomColor,
                selectedColor: $session.currentObjectProperties.color,
                metallic: $session.currentObjectProperties.metallic,
                roughness: $session.currentObjectProperties.roughness,
                emissiveIntensity: $session.currentObjectProperties.emissiveIntensity,
                selectedOpacity: $session.currentObjectProperties.opacity,
                needsText: session.currentObjectProperties.type.hasCustomText,
                textInput: $session.currentObjectProperties.text,
                needsProportionSlider: session.currentObjectProperties.type.hasCustomRatio,
                selectedProportion: $session.currentObjectProperties.ratio,
                rotationSpeed: $session.currentObjectProperties.rotationSpeed,
                rotationAxis: $session.currentObjectProperties.rotationAxis
            )
        }
        .sheet(isPresented: $session.showObjectsCatalog) {
            ObjectsCatalogSheetView(
                selectedType: $session.currentObjectProperties.type,
                selectedsticker: $session.currentObjectProperties.sticker
            )
        }
        .sheet(isPresented: $session.showInspirationSheet) {
            ChallengesView(
                completedChallenges: session.completedChallenges,
                selectedChallenge: $session.selectedChallenge,
                availableChallenges: session.availableChallenges
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
        ARVisionBoardView(board: VisionBoard())
    }
}
