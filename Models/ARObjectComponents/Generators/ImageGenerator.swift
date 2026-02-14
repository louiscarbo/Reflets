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
        if let id = object.imageID, 
           let url = getDocumentsDirectory()?.appendingPathComponent(id).appendingPathExtension("png") {
            entity = create2DEntityFromImage(
                url: url,
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
