//
//  ContentView.swift
//  TestRealityView
//
//  Created by Louis Carbo Estaque on 22/10/2024.
//

import SwiftUI
import RealityKit

struct UniqueIDComponent: Component {
    var id: Int
}

struct ARAutoportraitView: View {
    // App level state
    @Binding var screenNumber: Int
    
    // AR level state
    @State private var arObjects: [ARObject] = []
    @State private var selectedType: SelectedType = .sphere
    private var currentObjectType: ARObjectType {
        let scaleFactor = Float(sizeSliderValue * 5 + 0.5)

        switch selectedType {
        case .sphere:
            return .sphere(radius: 0.05 * scaleFactor)
        case .cube:
            return .cube(size: 0.1 * scaleFactor)
        case .cone:
            return .cone(radius: 0.05 * scaleFactor, height: Float(arObjectProperties.ratio * 0.05) * scaleFactor)
        case .cylinder:
            return .cylinder(radius: 0.05 * scaleFactor, height: Float(arObjectProperties.ratio * 0.05) * scaleFactor)
        case .text:
            return .text(content: arObjectProperties.text) // Text size adjustment could be separate
        case .image:
            return .text(content: "IMAGE") // Placeholder for image resizing
        }
    }
    @State private var lastObjectCount = 0
    @State private var nextEntityID = 0
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
                                        
                    // Create the new object entity
                    let newObject = arObjects.last!
                    let entity = newObject.generateEntity()
                    entity.components[UniqueIDComponent.self] = UniqueIDComponent(id: nextEntityID)
                    
                    // Create the anchor entity
                    let anchor = AnchorEntity(.camera)
                    anchor.anchoring.trackingMode = .once
                    anchor.addChild(entity)
                    anchor.components[UniqueIDComponent.self] = UniqueIDComponent(id: nextEntityID)
                    
                    content.add(anchor)
                                        
                    DispatchQueue.main.async {
                        nextEntityID += 1
                        lastObjectCount = arObjects.count
                    }
                }
                
                // Check if an object was removed
                else if arObjects.count < lastObjectCount {
                    
                    if content.entities.count > 0 {
                        let entityToRemoveID = nextEntityID - 1
                            
                        content.entities.removeAll(where: { entity in
                            if let uniqueIDComponent = entity.components[UniqueIDComponent.self] {
                                return uniqueIDComponent.id == entityToRemoveID
                            }
                            return false
                        })
                    }
                    
                    DispatchQueue.main.async {
                        nextEntityID -= 1
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
                shouldAddObject: $shouldAddObject,
                showCustomizationSheet: $showCustomizationSheet,
                arObjects: $arObjects,
                sliderValue: $sizeSliderValue
            )
            .onChange(of: shouldAddObject) {
                if shouldAddObject {
                    addCurrentObject()
                }
                shouldAddObject = false
            }
            .onChange(of: sizeSliderValue) {
                updatePlacementHelper = true
            }
            .sheet(isPresented: $showCustomizationSheet) {
                ObjectSettingsView(
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
