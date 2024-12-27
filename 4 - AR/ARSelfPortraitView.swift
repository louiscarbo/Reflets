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

struct ARSelfPortraitView: View {
    // App level state
    @Binding var screenNumber: Int
    
    // AR Objects
    let positioningHelperAnchor = AnchorEntity(.camera) // Anchor at the camera position
    @State private var arObjects: [ARObject] = []
    @State private var arObjectProperties = ARObjectProperties()
    
    // Intention
    @State var selectedIntention: Intention
    
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
                if arObjects.count > content.entities.count - 1 {
                    addNewEntity(in: content)
                }
                
                // Check if an object was removed
                else if arObjects.count < content.entities.count - 1 {
                    removeLastEntity(in: content)
                }
            }
            .ignoresSafeArea()
            
            // MARK: Controls Interface
            ARControlsView(
                artworkIsDone: .constant(false),
                arObjects: $arObjects,
                arObjectProperties: $arObjectProperties,
                selectedIntention: selectedIntention
            )
            .onChange(of: arObjectProperties) {
                updatePositioningHelper()
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
      
    func addNewEntity(in content: RealityViewCameraContent) {
        // Create the new object entity
        let newObject = arObjects.last!
        let entity = newObject.generateEntity()
        entity.components[UniqueIDComponent.self] = UniqueIDComponent(id: arObjects.count)
        
        // Create the anchor entity
        let anchor = AnchorEntity(.camera)
        anchor.anchoring.trackingMode = .once
        anchor.addChild(entity)
        anchor.components[UniqueIDComponent.self] = UniqueIDComponent(id: arObjects.count)
        
        print("Added entity with ID: \(arObjects.count)")
        content.add(anchor)
    }
    
    func removeLastEntity(in content: RealityViewCameraContent) {
        print("Removing entity with ID: \(arObjects.count + 1)")
        
        content.entities.removeAll(where: { entity in
            if let uniqueIDComponent = entity.components[UniqueIDComponent.self] {
                return uniqueIDComponent.id == arObjects.count + 1
            }
            return false
        })
    }
}

// MARK: Custom component for the positioning helper
struct PositioningHelperComponent: Component {}

#Preview {
    ARSelfPortraitView(
        screenNumber: .constant(5),
        selectedIntention: Intentions.proud.details)
}
