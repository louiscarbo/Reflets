//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI

struct ObjectSettingsView: View {
    @Binding var properties: ARObjectProperties
    
    private var needsColor: Bool { properties.type.hasCustomColor }
    private var needsText: Bool { properties.type.hasCustomText }
    private var needsProportionSlider: Bool { properties.type.hasCustomRatio }
    
    var body: some View {
        VStack {
            
            Text("Object settings")
                .font(.title)
                .fontWeight(.semibold)
                .fontWidth(.expanded)
            
            if needsColor {
                HStack {
                    Text("Color")
                        .fontWidth(.expanded)
                    Spacer()
                    ColorPicker("", selection: $properties.color, supportsOpacity: false)
                }
            }
            
            HStack {
                Text("Opacity")
                    .fontWidth(.expanded)
                Spacer()
                Slider(value: $properties.opacity)
                    .frame(width: 220)
            }
            
            if needsColor {
                HStack {
                    Text("Metallic")
                        .fontWidth(.expanded)
                    Spacer()
                    Slider(value: Binding(
                        get: { Double(properties.metallic) },
                        set: { properties.metallic = Float($0) }
                    ), in: 0...1)
                        .frame(width: 220)
                }
                
                HStack {
                    Text("Roughness")
                        .fontWidth(.expanded)
                    Spacer()
                    Slider(value: Binding(
                        get: { Double(properties.roughness) },
                        set: { properties.roughness = Float($0) }
                    ), in: 0...1)
                        .frame(width: 220)
                }
                
                HStack {
                    Text("Glow")
                        .fontWidth(.expanded)
                    Spacer()
                    Slider(value: Binding(
                        get: { Double(properties.emissiveIntensity) },
                        set: { properties.emissiveIntensity = Float($0) }
                    ), in: 0...5)
                        .frame(width: 220)
                }
            }
            
            HStack {
                Text("Rotation")
                    .fontWidth(.expanded)
                Spacer()
                Slider(value: Binding(
                    get: { Double(properties.rotationSpeed) },
                    set: { properties.rotationSpeed = Float($0) }
                ), in: 0...2)
                    .frame(width: 220)
            }
            
            if properties.rotationSpeed > 0 {
                HStack {
                    Text("Axis")
                        .fontWidth(.expanded)
                    Spacer()
                    Picker("Axis", selection: $properties.rotationAxis) {
                        ForEach(RotationAxis.allCases, id: \.self) { axis in
                            Image(systemName: axis.sfSymbolString)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }
            }
            
            if needsText {
                HStack {
                    Text("Text")
                        .fontWidth(.expanded)
                    Spacer()
                    TextField("Hello World!", text: $properties.text)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 220)
                }
            }
            
            if needsProportionSlider {
                HStack {
                    Text("Length")
                        .fontWidth(.expanded)
                    Spacer()
                    Slider(value: $properties.ratio, in: 0.1...7.0)
                        .frame(width: 220)
                }
            }
            
            Spacer()
        }
        .padding(25)
        .presentationDetents([.fraction(0.4), .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    @Previewable @State var isPresented = false;
    @Previewable @State var properties = ARObjectProperties(
        type: .text,
        color: .red,
        metallic: 1.0,
        roughness: 0.5,
        emissiveIntensity: 0.0,
        text: "Hello World!",
        ratio: 2.0,
        opacity: 0.9,
        size: 1.0,
        resizingFactor: 0.5,
        rotationSpeed: 0.0,
        rotationAxis: .y,
        sticker: nil
    )
    
    ZStack {
        Image("previewImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ARControlsView(session: .init(board: .init()))
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    ObjectSettingsView(properties: $properties)
                }
            }
    }
}
