//
//  TextGenerator.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import RealityKit
import UIKit

struct TextGenerator: EntityGeneratorStrategy {
    func generateEntity(for object: ARObject) -> Entity {
        let resizingFactor = object.resizingFactor * 0.4 + 0.01
        let scale = object.size * resizingFactor
        
        let mesh = MeshResource.generateText(
            object.text,
            extrusionDepth: 0.05,
            font: .systemFont(ofSize: CGFloat(scale)),
            containerFrame: CGRect.zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        
        let modelEntity = ModelEntity(mesh: mesh)
        modelEntity.model?.materials = [object.material]
        
        // Center the text
        let bounds = modelEntity.visualBounds(relativeTo: nil)
        let centerOffset = bounds.center
        
        let transformMatrix = Transform(
            translation: SIMD3(-centerOffset.x, -centerOffset.y, 0)
        ).matrix
        
        modelEntity.setTransformMatrix(transformMatrix, relativeTo: nil)
        
        return modelEntity
    }
}
