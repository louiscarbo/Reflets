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
        let scaleFactor = Float(arObjectProperties.size * 5 + 0.5)

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
            return .text(content: arObjectProperties.text, size: scaleFactor * 0.6)
        case .image:
            return .image(url: arObjectProperties.imageURL, size: scaleFactor * 0.3)
        }
    }
    @State private var lastObjectCount = 0
    @State private var shouldUpdatePositioningHelper = false
    @State private var dynamicCameraAnchor = AnchorEntity(.camera)
    
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
                content.add(dynamicCameraAnchor)
                
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
                sliderValue: $arObjectProperties.size
            )
            .onChange(of: arObjectProperties) {
                updatePositioningHelper()
            }
            .onChange(of: selectedType) {
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
                    needsColor: currentObjectType.hasCustomColor,
                    selectedColor: $arObjectProperties.color,
                    isMetallic: $arObjectProperties.metallic,
                    selectedOpacity: $arObjectProperties.opacity,
                    needsText: currentObjectType.hasCustomText,
                    textInput:  $arObjectProperties.text,
                    needsProportionSlider: currentObjectType.hasCustomRatio,
                    selectedProportion: $arObjectProperties.ratio
                )
            }
            .sheet(isPresented: $showObjectsCatalog) {
                ObjectsCatalogSheetView(
                    selectedType: $selectedType,
                    imageURL: $arObjectProperties.imageURL
                )
            }
        }
    }
    
    // MARK: AR Functions
    func updatePositioningHelper() {
        // Remove the previous Positioning Helper entity
        if let previousChild = dynamicCameraAnchor.children.first(where: {$0.components[PositioningHelperComponent.self] != nil}) {
            dynamicCameraAnchor.removeChild(previousChild)
        }
        
        // Create the new Positioning Helper entity
        let entity = ARObject(
            type: currentObjectType,
            color: SimpleMaterial(
                color: UIColor(arObjectProperties.color).withAlphaComponent(0.6 * arObjectProperties.opacity),
                isMetallic: arObjectProperties.metallic
            ),
            position: [0, 0, -1],
            imageOpacity: Float(0.5 * arObjectProperties.opacity)
        ).generateEntity()
        entity.components[PositioningHelperComponent.self] = PositioningHelperComponent()
        
        // Add the new Positioning Helper entity to the dynamicCameraAnchor
        dynamicCameraAnchor.addChild(entity)
    }
    
    func addCurrentObject() {
        let newObject = ARObject(
            type: currentObjectType,
            color: SimpleMaterial(
                color: UIColor(arObjectProperties.color).withAlphaComponent(arObjectProperties.opacity),
                isMetallic: arObjectProperties.metallic
            ),
            position: [0, 0, -1],
            imageOpacity: Float(arObjectProperties.opacity)
        )
        arObjects.append(newObject)
    }
}

// MARK: Custom component for the positioning helper
struct PositioningHelperComponent: Component {}

struct ARObjectProperties: Equatable {
    var color: Color = .yellow
    var metallic: Bool = true
    var text: String = "Hello!"
    var ratio: Double = 2.0
    var opacity: Double = 1.0
    var size: Double = 0.5
    var imageURL: URL? = nil
}

#Preview {
    ARAutoportraitView(screenNumber: .constant(5))
}
