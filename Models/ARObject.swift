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
    
    var isMetallic: Bool
    var text: String
    var ratio: Float
    var opacity: Double
    var size: Float
    var resizingFactor: Float
    
    // Relationship
    var customObject: CustomObject?
    
    // Position flattened from SIMD3<Float>
    var x: Float
    var y: Float
    var z: Float
    
    // Relationship
    var board: VisionBoard?
    
    init(type: ARObjectType = .sphere,
         color: Color = .yellow,
         isMetallic: Bool = true,
         text: String = "Hello!",
         ratio: Float = 2.0,
         opacity: Double = 1.0,
         size: Float = 1.0,
         resizingFactor: Float = 0.5,
         customObject: CustomObject? = nil,
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

        self.isMetallic = isMetallic
        self.text = text
        self.ratio = ratio
        self.opacity = opacity
        self.size = size
        self.resizingFactor = resizingFactor
        self.customObject = customObject
        
        self.x = position.x
        self.y = position.y
        self.z = position.z
    }
    
    convenience init(properties: ARObjectProperties, position: SIMD3<Float>) {
        self.init(
            type: properties.type,
            color: properties.color,
            isMetallic: properties.metallic,
            text: properties.text,
            ratio: properties.ratio,
            opacity: properties.opacity,
            size: properties.size,
            resizingFactor: properties.resizingFactor,
            customObject: properties.customObject,
            position: position
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
    
    var position: SIMD3<Float> {
        get { SIMD3(x, y, z) }
        set { x = newValue.x; y = newValue.y; z = newValue.z }
    }
    
    var material: SimpleMaterial {
        SimpleMaterial(
            color: UIColor(color.opacity(opacity)),
            isMetallic: isMetallic
        )
    }
}

// MARK: - Logic extension

extension ARObject {
    func generateEntity() -> Entity {
        let generator = EntityFactory.make(for: self.type)
        return generator.generateEntity(for: self)
    }
}
