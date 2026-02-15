//
//  ImageGenerator.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import RealityKit
import Foundation
import UIKit

struct ImageGenerator: EntityGeneratorStrategy {
    func generateEntity(for object: ARObject) -> Entity {
        let resizingFactor = object.resizingFactor * 0.4 + 0.01
        let scale = object.size * resizingFactor
        
        let entity: Entity
        if let customObject = object.customObject,
           let uiImage = customObject.uiImage {
            entity = create2DEntityFromImage(
                image: uiImage,
                imageID: customObject.id,
                size: scale * 3.5,
                opacity: object.opacity
            )
        } else {
            entity = Entity()
        }
        
        return entity
    }
}

private extension ImageGenerator {
    struct CachedTexture {
        let texture: TextureResource
        let aspectRatio: Float
    }

    static var textureCache: [UUID: CachedTexture] = [:]

    func createTextureFromPNG(image: UIImage, imageID: UUID) -> (TextureResource?, Float)? {
        if let cached = Self.textureCache[imageID] {
            return (cached.texture, cached.aspectRatio)
        }

        let aspectRatio = Float(image.size.width / image.size.height)
        guard let cgImage = image.cgImage else { return nil }
        
        do {
            let texture = try TextureResource(image: cgImage, options: .init(semantic: .normal))
            Self.textureCache[imageID] = CachedTexture(texture: texture, aspectRatio: aspectRatio)
            return (texture, aspectRatio)
        } catch {
            print("Error creating texture from image: \(error)")
            return nil
        }
    }
    
    func create2DEntityFromImage(image: UIImage, imageID: UUID, size: Float, opacity: Double = 1.0) -> Entity {
        guard let (texture, aspectRatio) = createTextureFromPNG(image: image, imageID: imageID) else {
            return Entity()
        }
        
        let width: Float = 0.5 * size
        let height: Float = width / aspectRatio
        let planeMesh = MeshResource.generatePlane(width: width, height: height)
        
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor.white.withAlphaComponent(CGFloat(opacity)), texture: .init(texture!))
        material.opacityThreshold = 0.01
        material.faceCulling = .none
        
        let modelEntity = ModelEntity(mesh: planeMesh, materials: [material])
        return modelEntity
    }
}
