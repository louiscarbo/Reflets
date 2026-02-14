//
//  ARVisionBoardView.swift
//  TestRealityView
//
//  Created by Louis Carbo Estaque on 22/10/2024.
//

import SwiftUI
import RealityKit
import SwiftData

struct UUIDComponent: Component {
    var uuid: UUID
}

struct ARVisionBoardView: View {
    @State private var viewModel: ARVisionBoardViewModel
    @State private var initialObjectIDs: Set<UUID> = []
    @State private var initialCameraTransform: simd_float4x4?
    
    init(board: VisionBoard) {
        self.viewModel = .init(board: board)
    }
    
    let positioningHelperAnchor = AnchorEntity(.camera)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: RealityView
            RealityView { content in
                content.camera = .spatialTracking
                content.add(positioningHelperAnchor)
                
                updatePositioningHelper()
                
                // Capture the initial camera transform for this session
                initialCameraTransform = positioningHelperAnchor.transformMatrix(relativeTo: nil)
                
                // Load all pre-existing objects from storage
                for object in viewModel.board.objects {
                    addExistingEntity(for: object, in: content)
                }
                
                // Track which objects were initially loaded
                initialObjectIDs = Set(viewModel.board.objects.map { $0.id })
                
            // MARK: Update closure
            } update: { content in
                let currentIDs = Set(viewModel.board.objects.map { $0.id })
                let existingIDs = Set(
                    content.entities.compactMap { $0.components[UUIDComponent.self]?.uuid }
                )
                
                // Detect additions (only objects added AFTER initial load)
                let addedIDs = currentIDs.subtracting(existingIDs).subtracting(initialObjectIDs)
                for object in viewModel.board.objects where addedIDs.contains(object.id) {
                    addNewEntity(for: object, in: content)
                    initialObjectIDs.insert(object.id)
                }
                
                // Detect removals
                let removedIDs = existingIDs.subtracting(currentIDs)
                for uuid in removedIDs {
                    removeEntity(with: uuid, in: content)
                }
            }
            .ignoresSafeArea()
            .onChange(of: viewModel.artworkIsDone) {
                if viewModel.artworkIsDone {
                    positioningHelperAnchor.children.removeAll()
                } else {
                    updatePositioningHelper()
                }
            }
            
            // MARK: Controls Interface
            if !viewModel.artworkIsDone {
                ARControlsView(
                    artworkIsDone: $viewModel.artworkIsDone,
                    arObjects: $viewModel.board.objects,
                    arObjectProperties: $viewModel.currentARObjectProperties
                )
                .onChange(of: viewModel.currentARObjectProperties) {
                    updatePositioningHelper()
                }
            }
            
            // MARK: Validation Interface
            if viewModel.artworkIsDone {
                ARValidationView(board: viewModel.board, artworkIsDone: $viewModel.artworkIsDone)
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
        var positioningHelperProperties = viewModel.currentARObjectProperties
        positioningHelperProperties.opacity /= 2
        let helperObject = ARObject(properties: positioningHelperProperties)
        let entity = helperObject.generateEntity()
        entity.components[PositioningHelperComponent.self] = PositioningHelperComponent()
        entity.position = [0, 0, -1]
        
        positioningHelperAnchor.addChild(entity)
    }
    
    /// Adds a pre-existing object loaded from storage at its stored offset from the initial camera
    func addExistingEntity(for object: ARObject, in content: RealityViewCameraContent) {
        guard let initialTransform = initialCameraTransform else {
            print("Warning: Initial camera transform not yet captured")
            return
        }
        
        let entity = object.generateEntity()
        
        // Apply the stored offset to the initial camera position
        let storedOffset = object.positionOffset
        
        // Create a transform that applies the offset in the camera's coordinate space
        // The offset is already in camera-relative coordinates
        var offsetTransform = initialTransform
        offsetTransform.columns.3.x += storedOffset.x
        offsetTransform.columns.3.y += storedOffset.y
        offsetTransform.columns.3.z += storedOffset.z
        
        let anchor = AnchorEntity(world: offsetTransform)
        anchor.addChild(entity)
        anchor.components[UUIDComponent.self] = UUIDComponent(uuid: object.id)
        
        content.add(anchor)
    }
      
    /// Adds a newly created object at the current camera/cursor position
    func addNewEntity(for object: ARObject, in content: RealityViewCameraContent) {
        guard let initialTransform = initialCameraTransform else {
            print("Warning: Initial camera transform not yet captured")
            return
        }
        
        // Create the entity at local origin
        let entity = object.generateEntity()
        
        guard let helperEntity = positioningHelperAnchor.children.first(where: {
            $0.components[PositioningHelperComponent.self] != nil 
        }) else {
            print("Warning: Positioning helper not found")
            return
        }
        
        let helperWorldTransform = helperEntity.transformMatrix(relativeTo: nil)
        let anchor = AnchorEntity(world: helperWorldTransform)
        anchor.addChild(entity)
        anchor.components[UUIDComponent.self] = UUIDComponent(uuid: object.id)
        
        // Compute and save the offset from the INITIAL camera position
        let initialPosition = SIMD3<Float>(
            initialTransform.columns.3.x,
            initialTransform.columns.3.y,
            initialTransform.columns.3.z
        )
        
        let finalPosition = SIMD3<Float>(
            helperWorldTransform.columns.3.x,
            helperWorldTransform.columns.3.y,
            helperWorldTransform.columns.3.z
        )
        
        let offset = finalPosition - initialPosition
        object.positionOffset = offset
        
        content.add(anchor)
    }
    
    func removeEntity(with uuid: UUID, in content: RealityViewCameraContent) {
        if let anchor = content.entities.first(where: {
            $0.components[UUIDComponent.self]?.uuid == uuid 
        }) {
            content.remove(anchor)
        }
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
