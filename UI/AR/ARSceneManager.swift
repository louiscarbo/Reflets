//
//  ARSceneManager.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import RealityKit
import SwiftUI

@MainActor
@Observable
class ARSceneManager {
    var initialCameraTransform: simd_float4x4?
    var initialObjectIDs: Set<UUID> = []
    private weak var positioningHelperEntity: Entity?
    
    func initialize(
        cameraAnchor: AnchorEntity,
        existingObjects: [ARObject],
        content: RealityViewCameraContent
    ) {
        self.initialCameraTransform = cameraAnchor.transformMatrix(relativeTo: nil)
        
        for object in existingObjects {
            addExistingEntity(for: object, in: content)
        }
        self.initialObjectIDs = Set(existingObjects.map { $0.id })
    }
    
    // MARK: - Entity Management
    
    /// Adds a pre-existing object loaded from storage at its stored offset from the initial camera
    func addExistingEntity(for object: ARObject, in content: RealityViewCameraContent) {
        guard let initialTransform = initialCameraTransform else {
            print("Warning: Initial camera transform not yet captured")
            return
        }
        
        let storedOffset = object.positionOffset
        let worldTransform = ARCoordinateSystem.computeWorldPosition(
            initialCameraTransform: initialTransform,
            storedOffset: storedOffset
        )
        
        let anchor = AnchorEntity(world: worldTransform)
        let entity = object.generateEntity()
        anchor.addChild(entity)
        anchor.components[UUIDComponent.self] = UUIDComponent(uuid: object.id)
        
        content.add(anchor)
        
        // Apply rotation animation AFTER anchoring
        object.applyRotationAnimation(to: entity)
    }
    
    /// Adds a newly created object at the current camera/cursor position (1m in front)
    func addNewEntity(for object: ARObject, in content: RealityViewCameraContent) {
        guard let initialTransform = initialCameraTransform else {
            print("Warning: Initial camera transform not yet captured")
            return
        }
        
        guard let positioningHelperEntity else {
            print("Warning: Positioning helper entity not available")
            return
        }
                
        let helperWorldTransform = positioningHelperEntity.transformMatrix(relativeTo: nil)
        
        let anchor = AnchorEntity(world: helperWorldTransform)
        let entity = object.generateEntity()
        anchor.addChild(entity)
        anchor.components[UUIDComponent.self] = UUIDComponent(uuid: object.id)
        
        // Compute and save the offset from the INITIAL camera position
        let initialPosition = ARCoordinateSystem.extractPosition(from: initialTransform)
        let finalPosition = ARCoordinateSystem.extractPosition(from: helperWorldTransform)
        let offset = ARCoordinateSystem.computeOffset(from: initialPosition, to: finalPosition)
        object.positionOffset = offset
        
        content.add(anchor)
        
        // Apply rotation animation AFTER anchoring
        object.applyRotationAnimation(to: entity)
    }
    
    /// Removes an entity by its UUID
    func removeEntity(with uuid: UUID, in content: RealityViewCameraContent) {
        
        if let anchor = content.entities.first(where: {
            $0.components[UUIDComponent.self]?.uuid == uuid
        }) {
            content.remove(anchor)
        }
    }
    
    // MARK: - Update Handling
    
    /// Handles the update cycle, detecting additions, removals, and updates
    func handleUpdate(
        content: RealityViewCameraContent,
        currentObjects: [ARObject]
    ) {
        let currentIDs = Set(currentObjects.map { $0.id })
        let existingIDs = Set(
            content.entities.compactMap { $0.components[UUIDComponent.self]?.uuid }
        )
        
        // Detect additions (only objects added AFTER initial load)
        let addedIDs = currentIDs.subtracting(existingIDs).subtracting(initialObjectIDs)
        for object in currentObjects where addedIDs.contains(object.id) {
            addNewEntity(for: object, in: content)
            initialObjectIDs.insert(object.id) // Track it as processed
        }
        
        // Detect removals
        let removedIDs = existingIDs.subtracting(currentIDs)
        for uuid in removedIDs {
            removeEntity(with: uuid, in: content)
        }
    }
    
    // MARK: - Positioning Helper
    
    /// Updates the positioning helper entity with new properties
    func updatePositioningHelper(
        with properties: ARObjectProperties,
        in helperAnchor: AnchorEntity
    ) {
        // Remove the previous positioning helper entity
        if let previousChild = helperAnchor.children.first(where: {
            $0.components[PositioningHelperComponent.self] != nil
        }) {
            helperAnchor.removeChild(previousChild)
        }
        
        var positioningHelperProperties = properties
        positioningHelperProperties.opacity /= 2
        
        let helperObject = ARObject(properties: positioningHelperProperties)
        let entity = helperObject.generateEntity()
        entity.components[PositioningHelperComponent.self] = PositioningHelperComponent()
        entity.position = [0, 0, -1]

        helperObject.applyRotationAnimation(to: entity)
        
        self.positioningHelperEntity = entity
        
        helperAnchor.addChild(entity)
    }
}

// MARK: - Custom Components

/// Component to identify the positioning helper entity
struct PositioningHelperComponent: Component {}

/// Component to track entities by their UUID
struct UUIDComponent: Component {
    var uuid: UUID
}
