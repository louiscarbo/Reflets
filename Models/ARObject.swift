//
//  ARObject.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 30/10/2024.
//

import SwiftData
import RealityKit
import Foundation
import UIKit
import SwiftUI

// MARK: - ARObject Model

@Model
final class ARObject {
    var id: UUID
    var type: ARObjectType
    
    // Properties flattened from ARObjectProperties
    var red: Double
    var green: Double
    var blue: Double
    
    var metallic: Float
    var roughness: Float
    var emissiveIntensity: Float
    var text: String
    var ratio: Float
    var opacity: Double
    var size: Float
    var resizingFactor: Float
    var rotationSpeed: Float
    var rotationAxisRawValue: String
    
    // Relationship
    var sticker: Sticker?
    
    // Position offset relative to initial camera position (not absolute world coordinates)
    // These represent where the object should be placed relative to the camera when the scene was created
    var x: Float
    var y: Float
    var z: Float
    
    // Relationship
    var board: VisionBoard?
    
    init(type: ARObjectType = .sphere,
         color: Color = .yellow,
         metallic: Float = 1.0,
         roughness: Float = 0.5,
         emissiveIntensity: Float = 0.0,
         text: String = "Hello!",
         ratio: Float = 2.0,
         opacity: Double = 1.0,
         size: Float = 1.0,
         resizingFactor: Float = 0.5,
         rotationSpeed: Float = 0.0,
         rotationAxis: RotationAxis = .y,
         sticker: Sticker? = nil,
         position: SIMD3<Float> = .zero) {
        
        self.id = UUID()
        self.type = type
        
       // Extract RGB
        if let components = color.cgColor?.components, components.count >= 3 {
             self.red = Double(components[0])
             self.green = Double(components[1])
             self.blue = Double(components[2])
        } else {
             // Fallback
             self.red = 1.0; self.green = 1.0; self.blue = 0.0
        }

        self.metallic = metallic
        self.roughness = roughness
        self.emissiveIntensity = emissiveIntensity
        self.text = text
        self.ratio = ratio
        self.opacity = opacity
        self.size = size
        self.resizingFactor = resizingFactor
        self.rotationSpeed = rotationSpeed
        self.rotationAxisRawValue = rotationAxis.rawValue
        self.sticker = sticker
        
        self.x = position.x
        self.y = position.y
        self.z = position.z
    }
    
    convenience init(properties: ARObjectProperties) {
        self.init(
            type: properties.type,
            color: properties.color,
            metallic: properties.metallic,
            roughness: properties.roughness,
            emissiveIntensity: properties.emissiveIntensity,
            text: properties.text,
            ratio: properties.ratio,
            opacity: properties.opacity,
            size: properties.size,
            resizingFactor: properties.resizingFactor,
            rotationSpeed: properties.rotationSpeed,
            rotationAxis: properties.rotationAxis,
            sticker: properties.sticker,
            position: .zero
        )
    }
}

// MARK: - Computed Properties extension

extension ARObject {
    var color: Color {
        get { Color(red: red, green: green, blue: blue) }
        set {
            if let components = newValue.cgColor?.components, components.count >= 3 {
                red = Double(components[0])
                green = Double(components[1])
                blue = Double(components[2])
            }
        }
    }
    
    var positionOffset: SIMD3<Float> {
        get { SIMD3(x, y, z) }
        set { x = newValue.x; y = newValue.y; z = newValue.z }
    }
    
    var rotationAxis: RotationAxis {
        get { RotationAxis(rawValue: rotationAxisRawValue) ?? .y }
        set { rotationAxisRawValue = newValue.rawValue }
    }
    
    var material: PhysicallyBasedMaterial {
        var mat = PhysicallyBasedMaterial()
        
        // Base color with opacity
        mat.baseColor = .init(tint: UIColor(color))
        
        // Blending mode for proper transparency
        mat.blending = .transparent(opacity: .init(floatLiteral: Float(opacity)))
        
        // Metallic (0-1 range)
        mat.metallic = .init(floatLiteral: metallic)
        
        // Roughness (0-1 range)
        mat.roughness = .init(floatLiteral: roughness)
        
        // Emissive using object's color
        if emissiveIntensity > 0 {
            mat.emissiveColor = .init(color: UIColor(color))
            mat.emissiveIntensity = emissiveIntensity
        }
        
        return mat
    }
}

// MARK: - Logic extension

extension ARObject {
    func generateEntity() -> Entity {
        let generator = EntityFactory.make(for: self.type)
        let entity = generator.generateEntity(for: self)
        return entity
    }
    
    /// Starts a rotation animation on an entity. Must be called AFTER the entity is anchored.
    func applyRotationAnimation(to entity: Entity) {
        guard rotationSpeed > 0 else { return }
        
        let duration: Double = Double(1 / rotationSpeed)
        let axis = rotationAxis.vector
        
        let currentPosition = entity.position
        
        let from = Transform(
            rotation: .init(angle: .pi, axis: axis),
            translation: currentPosition
        )

        let definition1 = FromToByAnimation(
            from: from,
            duration: duration,
            timing: .linear,
            bindTarget: .transform
        )
        
        let to = Transform(
            rotation: .init(angle: -1 * .pi, axis: axis),
            translation: currentPosition
        )
        
        let definition2 = FromToByAnimation(
            to: to,
            duration: duration,
            timing: .linear,
            bindTarget: .transform,
            delay: duration
        )
        
        let combinedDefinition = AnimationGroup(
            group: [definition1, definition2],
            repeatMode: .repeat
        )

        if let animate = try? AnimationResource.generate(with: combinedDefinition) {
            entity.playAnimation(animate)
        }
    }
}
