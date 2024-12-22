//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI

struct CustomizationSheetView: View {
    @Binding var updatePlacementHelper: Bool
    
    @Binding var selectedColor: Color
    @Binding var selectedOpacity: Double
    @Binding var isMetallic: Bool
    
    @Binding var needsText: Bool
    @Binding var textInput: String
    
    @Binding var needsProportionSlider: Bool
    @Binding var selectedProportion: Double
    
    var body: some View {
        VStack {
            
            Text("Object settings")
                .font(.title)
                .fontWeight(.semibold)
                .fontWidth(.expanded)
            
            HStack {
                Text("Color")
                    .fontWidth(.expanded)
                Spacer()
                ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                    .onSubmit {
                        updatePlacementHelper = true
                    }
            }
            
            HStack {
                Text("Opacity")
                    .fontWidth(.expanded)
                Spacer()
                Slider(value: $selectedOpacity)
                    .frame(width: 220)
                    .onSubmit {
                        updatePlacementHelper = true
                    }
            }
            
            HStack {
                Text("Metallic")
                    .fontWidth(.expanded)
                Spacer()
                Toggle(isOn: $isMetallic) { }
                    .onSubmit {
                        updatePlacementHelper = true
                    }
            }
            
            if needsText {
                HStack {
                    Text("Text")
                        .fontWidth(.expanded)
                    Spacer()
                    TextField("Hello World!", text: $textInput)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 220)
                        .onSubmit {
                            updatePlacementHelper = true
                        }
                }
            }
            
            if needsProportionSlider {
                HStack {
                    Text("Proportion")
                        .fontWidth(.expanded)
                    Spacer()
                    Slider(value: $selectedProportion)
                        .frame(width: 220)
                        .onSubmit {
                            updatePlacementHelper = true
                        }
                }
            }
            
            Spacer()
        }
        .padding(25)
        .presentationBackground(.thinMaterial)
        .presentationDetents([.fraction(0.4), .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(40.0)
    }
}

#Preview {
    @Previewable @State var isPresented = false;
    @Previewable @State var textInput = "Hello World!";
    
    ZStack {
        Image("previewImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ARControlsView(
            showReflectoHelp: .constant(false),
            showComponentsSheet: .constant(false),
            artworkIsDone: .constant(false),
            shouldGoBack: .constant(false),
            shouldAddObject: .constant(false),
            showCustomizationSheet: $isPresented,
            sliderValue: .constant(0.8)
        )
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                CustomizationSheetView(
                    updatePlacementHelper: .constant(true),
                    selectedColor: .constant(.red),
                    selectedOpacity: .constant(0.9),
                    isMetallic: .constant(true),
                    needsText: .constant(true),
                    textInput: $textInput,
                    needsProportionSlider: .constant(true),
                    selectedProportion: .constant(1.0)
                )
            }
        }
    }
}
