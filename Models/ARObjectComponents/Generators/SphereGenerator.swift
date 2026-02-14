//
//  SphereGenerator.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import RealityKit

struct SphereGenerator: EntityGeneratorStrategy {
    func generateEntity(for object: ARObject) -> Entity {
        let scale = object.size * (object.resizingFactor * 0.4 + 0.01)
        let mesh = MeshResource.generateSphere(radius: scale)
        let modelEntity = ModelEntity(mesh: mesh)
        modelEntity.model?.materials = [object.material]
        return modelEntity
    }
}
