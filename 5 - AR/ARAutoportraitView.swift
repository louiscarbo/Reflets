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
    @State private var lastObjectCount = 0
    @State private var shouldUpdatePositioningHelper = false
    let positioningHelperAnchor = AnchorEntity(.camera) // Anchor at the camera position
    
    // Entity ID management
    @State private var nextEntityID = 0
    
    // Properties of the AR Object
    @State private var arObjectProperties = ARObjectProperties()
    
    // Properties of the controls
    @State private var showObjectsCatalog = false
    @State private var showCustomizationSheet = false
    @State private var shouldAddObject = false
            
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: RealityView
            RealityView { content in
                content.camera = .spatialTracking
                content.add(positioningHelperAnchor)
                
                // Addind the positioning helper
                updatePositioningHelper()
                
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
                    
                    print("Added entity with ID: \(nextEntityID)")
                    content.add(anchor)
                                        
                    DispatchQueue.main.async {
                        print("Incrementing nextEntityID")
                        nextEntityID += 1
                        lastObjectCount = arObjects.count
                    }
                }
                
                // Check if an object was removed
                else if arObjects.count < lastObjectCount {
                    
                    if content.entities.count > 0 {
                        print("Removing entity with ID: \(nextEntityID - 1)")
                        let entityToRemoveID = nextEntityID - 1
                            
                        content.entities.removeAll(where: { entity in
                            if let uniqueIDComponent = entity.components[UniqueIDComponent.self] {
                                return uniqueIDComponent.id == entityToRemoveID
                            }
                            return false
                        })
                    }
                    
                    DispatchQueue.main.async {
                        print("Decrementing nextEntityID")
                        nextEntityID -= 1
                        lastObjectCount = arObjects.count
                    }
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
                sliderValue: $arObjectProperties.resizingFactor
            )
            .onChange(of: arObjectProperties) {
                updatePositioningHelper()
            }
            .onChange(of: shouldAddObject) {
                if shouldAddObject {
                    addCurrentObject()
                }
                shouldAddObject = false
            }
            .sheet(isPresented: $showCustomizationSheet) {
                ObjectSettingsView(
                    needsColor: arObjectProperties.type.hasCustomColor,
                    selectedColor: $arObjectProperties.color,
                    isMetallic: $arObjectProperties.metallic,
                    selectedOpacity: $arObjectProperties.opacity,
                    needsText: arObjectProperties.type.hasCustomText,
                    textInput:  $arObjectProperties.text,
                    needsProportionSlider: arObjectProperties.type.hasCustomRatio,
                    selectedProportion: $arObjectProperties.ratio
                )
            }
            .sheet(isPresented: $showObjectsCatalog) {
                ObjectsCatalogSheetView(
                    selectedType: $arObjectProperties.type,
                    imageURL: $arObjectProperties.imageURL
                )
            }
        }
    }
    
    // MARK: AR Functions
    func updatePositioningHelper() {
        // Remove the previous Positioning Helper entity
        if let previousChild = positioningHelperAnchor.children.first(where: {$0.components[PositioningHelperComponent.self] != nil}) {
            positioningHelperAnchor.removeChild(previousChild)
        }
        
        // Create the new Positioning Helper entity
        var positioningHelperProperties = arObjectProperties
        positioningHelperProperties.opacity = 0.5 * arObjectProperties.opacity
        let entity = ARObject(
            properties: positioningHelperProperties,
            position: [0, 0, -1]
        ).generateEntity()
        entity.components[PositioningHelperComponent.self] = PositioningHelperComponent()
        
        // Add the new Positioning Helper entity to the dynamicCameraAnchor
        positioningHelperAnchor.addChild(entity)
    }
    
    func addCurrentObject() {
        let newObject = ARObject(
            properties: arObjectProperties,
            position: [0, 0, -1]
        )
        arObjects.append(newObject)
    }
}

// MARK: Custom component for the positioning helper
struct PositioningHelperComponent: Component {}

#Preview {
    ARAutoportraitView(screenNumber: .constant(5))
}
