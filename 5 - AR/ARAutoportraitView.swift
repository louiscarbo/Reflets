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
            return .cone(radius: 0.05, height: Float(arObjectProperties.ratio * 0.05))
        case .cylinder:
            return .cylinder(radius: 0.05, height: Float(arObjectProperties.ratio * 0.05))
        case .text:
            return .text(content: arObjectProperties.text)
        case .image:
            return .text(content: "IMAGE")
            //TODO: Implement image loading
        }
    }
    @State private var lastObjectCount = 0
    @State private var updatePlacementHelper = false
    @State private var shouldUpdatePlacementHelper = false
    
    // Properties of the AR Object
    @State private var arObjectProperties = ARObjectProperties(color: .yellow, metallic: true, text: "Hello", ratio: 2.0, opacity: 1.0)
    
    // Properties of the controls
    @State private var showObjectsCatalog = false
    @State private var showCustomizationSheet = false
    @State private var shouldGoBack = false
    @State private var shouldAddObject = false
    @State private var sizeSliderValue: Double = 0.5
        
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
            ARControlsView(
                showReflectoHelp: .constant(false),
                showObjectsCatalog: $showObjectsCatalog,
                artworkIsDone: .constant(false),
                shouldGoBack: $shouldGoBack,
                shouldAddObject: $shouldAddObject,
                showCustomizationSheet: $showCustomizationSheet,
                sliderValue: $sizeSliderValue
            )
            .onChange(of: shouldAddObject) {
                if shouldAddObject {
                    addCurrentObject()
                }
                shouldAddObject = false
            }
            .sheet(isPresented: $showCustomizationSheet) {
                CustomizationSheetView(
                    selectedColor: $arObjectProperties.color,
                    selectedOpacity: $arObjectProperties.opacity,
                    isMetallic: $arObjectProperties.metallic,
                    needsText: currentObjectType.hasCustomText,
                    textInput:  $arObjectProperties.text,
                    needsProportionSlider: currentObjectType.hasCustomRatio,
                    selectedProportion: $arObjectProperties.ratio
                )
                .onChange(of: arObjectProperties) {
                    updatePlacementHelper = true
                }
                .onChange(of: shouldGoBack) {
                    goBack()
                    shouldGoBack = false
                }
            }
            .sheet(isPresented: $showObjectsCatalog) {
                ObjectsCatalogSheetView(selectedType: $selectedType)
                    .onChange(of: selectedType) {
                        updatePlacementHelper = true
                    }
            }
        }
    }
    
    // MARK: AR Functions
    func createPositioningHelper() -> AnchorEntity {
        let entity = ARObject(
            type: currentObjectType,
            color: SimpleMaterial(
                color: UIColor(arObjectProperties.color).withAlphaComponent(0.6),
                isMetallic: arObjectProperties.metallic
            ),
            position: [0, 0, -1]
        ).generateEntity()
        
        let dynamicCameraAnchor = AnchorEntity(.camera)
        dynamicCameraAnchor.addChild(entity)
        dynamicCameraAnchor.components[PositioningHelperComponent.self] = PositioningHelperComponent()
        
        return dynamicCameraAnchor
    }
    
    func addCurrentObject() {
        let newObject = ARObject(
            type: currentObjectType,
            color: SimpleMaterial(
                color: UIColor(arObjectProperties.color).withAlphaComponent(arObjectProperties.opacity),
                isMetallic: arObjectProperties.metallic
            ),
            position: [0, 0, -1]
        )
        arObjects.append(newObject)
    }
    
    func goBack() {
        if !arObjects.isEmpty {
            arObjects.removeLast()
        }
    }
}

// MARK: Custom component for the positioning helper
struct PositioningHelperComponent: Component {}

struct ARObjectProperties: Equatable {
    var color: Color
    var metallic: Bool
    var text: String
    var ratio: Double
    var opacity: Double
}

#Preview {
    ARAutoportraitView(screenNumber: .constant(5))
}
