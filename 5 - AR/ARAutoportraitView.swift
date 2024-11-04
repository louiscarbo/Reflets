//
//  ContentView.swift
//  TestRealityView
//
//  Created by Louis Carbo Estaque on 22/10/2024.
//

import SwiftUI
import RealityKit

struct ARAutoportraitView: View {
    // App level state
    @Binding var screenNumber: Int
    
    // AR level state
    @State private var arObjects: [ARObject] = []
    @State private var selectedType: SelectedType = .sphere
    private var currentObjectType: ARObjectType {
        switch selectedType {
        case .sphere:
            return .sphere(radius: 0.05)
        case .cube:
            return .cube(size: 0.1)
        case .cone:
            return .cone(radius: 0.05, height: Float(arObjectRatio * 0.05))
        case .cylinder:
            return .cylinder(radius: 0.05, height: Float(arObjectRatio * 0.05))
        case .text:
            return .text(content: arObjectText)
        case .image:
            return .text(content: "IMAGE")
            //TODO: Implement image loading
        }
    }
    @State private var lastObjectCount = 0
    @State private var updatePlacementHelper = false
    
    // Properties of the AR Object
    @State private var arObjectColor = Color.yellow
    @State private var arObjectMetallic = true
    @State private var arObjectText = "Hello"
    @State private var arObjectRatio = 2.0
    @State private var arObjectOpacity = 1.0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: RealityView
            RealityView { content in
                content.camera = .spatialTracking
                
                // Example URL for the PNG (use your actual image URL here)
                if let url = getSegmentedImageURL() {
                    let entity = create2DEntityFromImage(url: url)
                    content.add(entity)
                }
                
                // Addind the positioning helper
                let positioningHelper = createPositioningHelper()
                content.add(positioningHelper)
                
            // MARK: Update closure
            } update: { content in
                // Check if an object was added
                if arObjects.count > lastObjectCount {
                    let newObject = arObjects.last!
                    let entity = newObject.generateEntity()
                    let anchor = AnchorEntity(.camera)
                    anchor.anchoring.trackingMode = .once
                    anchor.addChild(entity)
                    content.add(anchor)
                    
                    DispatchQueue.main.async {
                        lastObjectCount = arObjects.count
                    }
                }
                
                // Check if an object was removed
                else if arObjects.count < lastObjectCount {
                    // Remove the last object from the scene
                    content.entities.remove(at: content.entities.count - 1)
                    
                    DispatchQueue.main.async {
                        lastObjectCount = arObjects.count
                    }
                }
                
                // Update the positioning helper according to the current object type
                if updatePlacementHelper {
                    content.entities.removeAll { entity in
                        entity.components[PositioningHelperComponent.self] != nil // Detects entities with the helper component
                    }
                    let positioningHelper = createPositioningHelper()
                    content.add(positioningHelper)
                }
            }
            .ignoresSafeArea()
            
            // MARK: Controls Interface
            VStack {
                Slider(value: $arObjectOpacity, in: 0.0...1.0, label: {
                    Text("Opacity")
                })
                .onSubmit {
                    updatePlacementHelper = true
                }
                if currentObjectType.hasCustomColor {
                    Toggle("Metallic", isOn: $arObjectMetallic)
                        .onSubmit {
                            updatePlacementHelper = true
                        }
                    ColorPicker("Object Color", selection: $arObjectColor)
                        .onSubmit {
                            updatePlacementHelper = true
                        }
                }

                if currentObjectType.hasCustomText {
                    TextField("Enter Text", text: $arObjectText)
                        .onSubmit {
                            updatePlacementHelper = true
                        }
                }

                if currentObjectType.hasCustomRatio {
                    Slider(value: $arObjectRatio, in: 0.5...10.0, label: {
                        Text("Ratio")
                    })
                    .onSubmit {
                        updatePlacementHelper = true
                    }
                }
                
                Picker("Object Type", selection: $selectedType) {
                    Text("Sphere").tag(SelectedType.sphere)
                    Text("Cube").tag(SelectedType.cube)
                    Text("Cone").tag(SelectedType.cone)
                    Text("Cylinder").tag(SelectedType.cylinder)
                    Text("Text").tag(SelectedType.text)
                }
                .onChange(of: selectedType) {
                    updatePlacementHelper = true
                }
                
                HStack {
                    Button("Add Object") {
                        let newObject = ARObject(type: currentObjectType, color: SimpleMaterial(color: UIColor(arObjectColor).withAlphaComponent(arObjectOpacity), isMetallic: arObjectMetallic), position: [0, 0, -1])
                        arObjects.append(newObject)
                    }
                    .buttonBorderShape(.capsule)
                    .padding()
                    .buttonStyle(.borderedProminent)
                    
                    Button("Back") {
                        if !arObjects.isEmpty {
                            arObjects.removeLast()
                        }
                    }
                    .buttonBorderShape(.capsule)
                    .padding()
                    .buttonStyle(.borderedProminent)
                }
            }

            AutoportraitCommandsView(screenNumber: $screenNumber)
        }
    }
    
    // MARK: AR Functions
    func createPositioningHelper() -> AnchorEntity {
        let entity = ARObject(type: currentObjectType, color: SimpleMaterial(color: UIColor(arObjectColor).withAlphaComponent(0.6), isMetallic: arObjectMetallic), position: [0, 0, -1]).generateEntity()
        
        let dynamicCameraAnchor = AnchorEntity(.camera)
        dynamicCameraAnchor.addChild(entity)
        dynamicCameraAnchor.components[PositioningHelperComponent.self] = PositioningHelperComponent()
        
        return dynamicCameraAnchor
    }
}

// MARK: Custom component for the positioning helper
struct PositioningHelperComponent: Component {}

#Preview {
    ARAutoportraitView(screenNumber: .constant(5))
}
