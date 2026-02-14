//
//  CylinderGenerator.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import RealityKit

struct CylinderGenerator: EntityGeneratorStrategy {
    func generateEntity(for object: ARObject) -> Entity {
        let resizingFactor = object.resizingFactor * 0.4 + 0.01
        let scale = object.size * resizingFactor
        
        let mesh = MeshResource.generateCylinder(
            height: object.ratio * scale,
            radius: scale
        )
        let modelEntity = ModelEntity(mesh: mesh)
        modelEntity.model?.materials = [object.material]
        modelEntity.position = object.position
        return modelEntity
    }
}
