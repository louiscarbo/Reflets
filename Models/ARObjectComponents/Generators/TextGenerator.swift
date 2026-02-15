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

        // Center the text around its local origin
        let bounds = modelEntity.visualBounds(relativeTo: modelEntity)
        let centerOffset = bounds.center

        modelEntity.position = SIMD3(-centerOffset.x, -centerOffset.y, -centerOffset.z)

        let container = Entity()
        container.addChild(modelEntity)
        return container
    }
}
