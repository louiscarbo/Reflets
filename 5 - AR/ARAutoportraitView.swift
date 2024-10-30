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
    
    @State private var addSphere: Bool = false
    
    @State private var arObjects: [ARObject] = []
    @State private var currentObjectType: ARObjectType = .sphere(radius: 0.05)

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
                let positioningHelper = createPositioningHelper()
                content.add(positioningHelper)
                
            } update: { content in
                if addSphere {
                    let sphereAnchor = createYellowMetallicSphere()
                    content.add(sphereAnchor)

                    DispatchQueue.main.async {
                        addSphere = false
                    }
                }
            }
            .ignoresSafeArea()
            
            Button("Add sphere") {
                addSphere = true
            }
            .padding()
            .buttonBorderShape(.capsule)
            .background(.yellow)
            
            AutoportraitCommandsView(screenNumber: $screenNumber)
        }
    }
}

// Function to create a yellow metallic sphere
func createYellowMetallicSphere() -> AnchorEntity {
    let sphereMesh = MeshResource.generateSphere(radius: 0.05)
    let material = SimpleMaterial(color: .yellow, isMetallic: true)
    let modelComponent = ModelComponent(mesh: sphereMesh, materials: [material])
    let sphereEntity = ModelEntity()
    sphereEntity.components.set(modelComponent)
    
    let cameraAnchor = AnchorEntity(.camera)
    cameraAnchor.anchoring.trackingMode = .once
    
    sphereEntity.position = [0, 0, -1]
    cameraAnchor.addChild(sphereEntity)
    
    return cameraAnchor
}

// Function to add a transparent yellow metallic sphere to help the user place the object
func createPositioningHelper() -> AnchorEntity {
    let dynamicCameraAnchor = AnchorEntity(.camera)
    let sphereMesh = MeshResource.generateSphere(radius: 0.05)
    let material = SimpleMaterial(color: .yellow.withAlphaComponent(0.5), isMetallic: true)
    let modelComponent = ModelComponent(mesh: sphereMesh, materials: [material])
    let sphereEntity = ModelEntity()
    sphereEntity.position = [0, 0, -1]
    sphereEntity.components.set(modelComponent)
    dynamicCameraAnchor.addChild(sphereEntity)
    
    return dynamicCameraAnchor
}

#Preview {
    ARAutoportraitView(screenNumber: .constant(5))
}
