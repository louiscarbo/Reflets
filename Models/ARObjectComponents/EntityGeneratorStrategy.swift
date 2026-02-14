//
//  EntityGeneratorStrategy.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import RealityKit

protocol EntityGeneratorStrategy {
    func generateEntity(for object: ARObject) -> Entity
}

struct EntityFactory {
    static func make(for type: ARObjectType) -> EntityGeneratorStrategy {
        switch type {
        case .sphere:
            return SphereGenerator()
        case .cube:
            return CubeGenerator()
        case .cone:
            return ConeGenerator()
        case .cylinder:
            return CylinderGenerator()
        case .text:
            return TextGenerator()
        case .image:
            return ImageGenerator()
        }
    }
}
