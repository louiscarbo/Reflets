//
//  ImageGenerator.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import RealityKit
import Foundation

struct ImageGenerator: EntityGeneratorStrategy {
    func generateEntity(for object: ARObject) -> Entity {
        let resizingFactor = object.resizingFactor * 0.4 + 0.01
        let scale = object.size * resizingFactor
        
        let entity: Entity
        if let customObject = object.customObject,
           let uiImage = customObject.uiImage {
            entity = create2DEntityFromImage(
                image: uiImage,
                size: scale * 3.5,
                opacity: object.opacity
            )
        } else {
            entity = Entity()
        }
        
        entity.position = object.position
        return entity
    }
}
