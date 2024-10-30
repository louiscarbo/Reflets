//
//  ContentView.swift
//  TestRealityView
//
//  Created by Louis Carbo Estaque on 22/10/2024.
//

import SwiftUI
import RealityKit

struct ARAutoportraitView: View {
    @Binding var screenNumber: Int
        
    @State private var arObjects: [ARObject] = []
    @State private var currentObjectType: ARObjectType = .cylinder(radius: 0.05, height: 0.2)
    @State private var lastObjectCount = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            RealityView { content in
                content.camera = .spatialTracking
                
                // Example URL for the PNG (use your actual image URL here)
                if let url = getSegmentedImageURL() {
                    let entity = create2DEntityFromImage(url: url)
                    content.add(entity)
                }
                
                // Addind the positioning helper
                let positioningHelper = createPositioningHelper(currentObjectType: currentObjectType)
                content.add(positioningHelper)
                
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
            }
            .ignoresSafeArea()
            
            HStack {
                Button("Add Object") {
                    let newObject = ARObject(type: currentObjectType, color: SimpleMaterial(color: .yellow, isMetallic: true), position: [0, 0, -1])
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

            AutoportraitCommandsView(screenNumber: $screenNumber)
        }
    }
}

// Function to add a transparent yellow metallic sphere to help the user place the object
func createPositioningHelper(currentObjectType: ARObjectType) -> AnchorEntity {
    let entity = ARObject(type: currentObjectType, color: SimpleMaterial(color: .yellow.withAlphaComponent(0.6), isMetallic: true), position: [0, 0, -1]).generateEntity()
    
    let dynamicCameraAnchor = AnchorEntity(.camera)
    dynamicCameraAnchor.addChild(entity)
    
    return dynamicCameraAnchor
}

#Preview {
    ARAutoportraitView(screenNumber: .constant(5))
}
