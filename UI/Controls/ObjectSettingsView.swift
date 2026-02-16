//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI

// MARK: - Main View
struct ObjectSettingsView: View {
    @Environment(\.editingSession) private var session

    var body: some View {
        @Bindable var bindableSession = session
        
        ScrollView {
            VStack(spacing: 20) {
                Text("Object settings")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                MaterialSettingsView(properties: $bindableSession.currentObjectProperties)
                
                RotationSettingsView(properties: $bindableSession.currentObjectProperties)
                
                ShapeSettingsView(properties: $bindableSession.currentObjectProperties)
                
                TextSettingsView(properties: $bindableSession.currentObjectProperties)
            }
            .padding(20)
            .background {
                RandomSymbolsView()
            }
        }
        .presentationDetents([.fraction(0.4), .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Material Settings
struct MaterialSettingsView: View {
    @Binding var properties: ARObjectProperties
    
    var body: some View {
        SettingsGroupView(title: "Material", icon: "paintpalette.fill") {
            if properties.type.hasCustomColor {
                SettingRow(label: "Color") {
                    ColorPicker("", selection: $properties.color, supportsOpacity: false)
                }
            }
            
            SettingRow(label: "Opacity") {
                Slider(value: $properties.opacity)
                    .frame(width: 220)
            }
            
            if properties.type.hasCustomColor {
                SettingRow(label: "Metallic") {
                    Slider(value: Binding(
                        get: { Double(properties.metallic) },
                        set: { properties.metallic = Float($0) }
                    ), in: 0...1)
                    .frame(width: 220)
                }
                
                SettingRow(label: "Roughness") {
                    Slider(value: Binding(
                        get: { Double(properties.roughness) },
                        set: { properties.roughness = Float($0) }
                    ), in: 0...1)
                    .frame(width: 220)
                }
                
                SettingRow(label: "Glow") {
                    Slider(value: Binding(
                        get: { Double(properties.emissiveIntensity) },
                        set: { properties.emissiveIntensity = Float($0) }
                    ), in: 0...5)
                    .frame(width: 220)
                }
            }
        }
    }
}

// MARK: - Rotation Settings
struct RotationSettingsView: View {
    @Binding var properties: ARObjectProperties
    
    var body: some View {
        SettingsGroupView(title: "Rotation", icon: "rotate.3d") {
            SettingRow(label: "Speed") {
                Slider(value: Binding(
                    get: { Double(properties.rotationSpeed) },
                    set: { properties.rotationSpeed = Float($0) }
                ), in: 0...2)
                .frame(width: 220)
            }
            
            if properties.rotationSpeed > 0 {
                SettingRow(label: "Axis") {
                    Picker("Axis", selection: $properties.rotationAxis) {
                        ForEach(RotationAxis.allCases, id: \.self) { axis in
                            Image(systemName: axis.sfSymbolString)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 220)
                }
            }
        }
    }
}

// MARK: - Shape Settings
struct ShapeSettingsView: View {
    @Binding var properties: ARObjectProperties
    
    var body: some View {
        if properties.type.hasCustomRatio {
            SettingsGroupView(title: "Shape", icon: "cube.fill") {
                SettingRow(label: "Length") {
                    Slider(value: $properties.ratio, in: 0.1...7.0)
                        .frame(width: 220)
                }
            }
        }
    }
}

// MARK: - Text Settings
struct TextSettingsView: View {
    @Binding var properties: ARObjectProperties
    
    var body: some View {
        if properties.type.hasCustomText {
            SettingsGroupView(title: "Text", icon: "textformat") {
                SettingRow(label: "Text") {
                    TextField("Hello World!", text: $properties.text)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 220)
                }
            }
        }
    }
}

// MARK: - Helper Views
struct SettingsGroupView<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
                    .fontWidth(.expanded)
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 16) {
                content
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}

struct SettingRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content
    
    var body: some View {
        HStack {
            Text(label)
                .fontWidth(.expanded)
            Spacer()
            content
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false;
    
    ZStack {
        Image("previewImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ARControlsView(session: .init(board: .init()))
            .sheet(isPresented: $isPresented) {
                NavigationStack {
                    ObjectSettingsView()
                }
            }
            .environment(\.editingSession, .init(board: .init()))
    }
}
