//
//  ARVisionBoardView.swift
//  TestRealityView
//
//  Created by Louis Carbo Estaque on 22/10/2024.
//

import SwiftUI
import RealityKit
import SwiftData

struct UniqueIDComponent: Component {
    var id: Int
}

struct ARVisionBoardView: View {
    // App level state
    @Bindable var board: VisionBoard
    @State private var artworkIsDone: Bool = false
    
    // AR Objects
    let positioningHelperAnchor = AnchorEntity(.camera) // Anchor at the camera position
    @State private var arObjectProperties = ARObjectProperties()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: RealityView
            RealityView { content in
                content.camera = .spatialTracking
                content.add(positioningHelperAnchor)
                
                updatePositioningHelper()
                
            // MARK: Update closure
            } update: { content in
                // Check if an object was added
                if board.objects.count > content.entities.count - 1 {
                    addNewEntity(in: content)
                }
                
                // Check if an object was removed
                else if board.objects.count < content.entities.count - 1 {
                    removeLastEntity(in: content)
                }
            }
            .ignoresSafeArea()
            .onChange(of: artworkIsDone) {
                if artworkIsDone {
                    positioningHelperAnchor.children.removeAll()
                } else {
                    updatePositioningHelper()
                }
            }
            
            // MARK: Controls Interface
            if !artworkIsDone {
                ARControlsView(
                    artworkIsDone: $artworkIsDone,
                    arObjects: $board.objects,
                    arObjectProperties: $arObjectProperties
                )
                .onChange(of: arObjectProperties) {
                    updatePositioningHelper()
                }
            }
            
            // MARK: Validation Interface
            if artworkIsDone {
                ARValidationView(board: board, artworkIsDone: $artworkIsDone)
            }
        }
    }
    
    // MARK: AR Functions
    func updatePositioningHelper() {
        // Remove the previous Positioning Helper entity
        if let previousChild = positioningHelperAnchor.children.first(where: { $0.components[PositioningHelperComponent.self] != nil }) {
            positioningHelperAnchor.removeChild(previousChild)
        }
        
        // Create the new Positioning Helper entity
        var positioningHelperProperties = arObjectProperties
        positioningHelperProperties.opacity = 0.5 * arObjectProperties.opacity
        
        // Use the convenience init I added to ARObject class
        let tempObject = ARObject(
            properties: positioningHelperProperties,
            position: [0, 0, -1]
        )
        let entity = tempObject.generateEntity()
        entity.components[PositioningHelperComponent.self] = PositioningHelperComponent()
        
        // Add the new Positioning Helper entity to the dynamicCameraAnchor
        positioningHelperAnchor.addChild(entity)
    }
      
    func addNewEntity(in content: RealityViewCameraContent) {
        // Create the new object entity
        guard let newObject = board.objects.last else { return }
        let entity = newObject.generateEntity()
        entity.components[UniqueIDComponent.self] = UniqueIDComponent(id: board.objects.count)
        
        // We take the current camera transform. The object itself has an offset of -1 (z) 
        // which places it correctly in front of the camera.
        let finalTransform = positioningHelperAnchor.transformMatrix(relativeTo: nil)
        
        // Create a world anchor fixed at the camera position
        let anchor = AnchorEntity(world: finalTransform)
        anchor.addChild(entity)
        anchor.components[UniqueIDComponent.self] = UniqueIDComponent(id: board.objects.count)
        
        print("Added entity with ID: \(board.objects.count)")
        content.add(anchor)
    }
    
    func removeLastEntity(in content: RealityViewCameraContent) {
        print("Removing entity with ID: \(board.objects.count + 1)")
        
        content.entities.removeAll(where: { entity in
            if let uniqueIDComponent = entity.components[UniqueIDComponent.self] {
                return uniqueIDComponent.id == board.objects.count + 1
            }
            return false
        })
    }
}

// MARK: Custom component for the positioning helper
struct PositioningHelperComponent: Component {}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VisionBoard.self, configurations: config)
    let board = VisionBoard()
    
    return ZStack {
        GeometryReader { geometry in
            Image("previewImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        ARVisionBoardView(board: board)
    }
    .modelContainer(container)
}
