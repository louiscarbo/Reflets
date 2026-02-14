//
//  TextureUtils.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import Foundation
import UIKit
import RealityKit

// MARK: - Image & Texture Helpers

func loadPNGFromURL(url: URL) -> UIImage? {
    if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
        return uiImage
    } else {
        print("Error loading image from URL: \(url)")
        return nil
    }
}

func createTextureFromPNG(image: UIImage) -> (TextureResource?, Float)? {
    let aspectRatio = Float(image.size.width / image.size.height)
    guard let cgImage = image.cgImage else { return nil }
    
    do {
        let texture = try TextureResource(image: cgImage, options: .init(semantic: .normal))
        return (texture, aspectRatio)
    } catch {
        print("Error creating texture from image: \(error)")
        return nil
    }
}

func create2DEntityFromImage(url: URL, size: Float, opacity: Double = 1.0) -> Entity {
    guard let uiImage = loadPNGFromURL(url: url),
          let (texture, aspectRatio) = createTextureFromPNG(image: uiImage) else {
        return Entity()
    }

    let width: Float = 0.5 * size
    let height: Float = width / aspectRatio
    let planeMesh = MeshResource.generatePlane(width: width, height: height)

    var material = UnlitMaterial()
    material.color = .init(tint: UIColor.white.withAlphaComponent(CGFloat(opacity)), texture: .init(texture!))
    material.opacityThreshold = 0.01
    material.faceCulling = .none

    let modelComponent = ModelComponent(mesh: planeMesh, materials: [material])
    let entity = ModelEntity()
    entity.components.set(modelComponent)
    // The original code had a fixed position here, which might be undesirable in a generic utility but keeping for consistency
    entity.position = [0, 0, -1] 

    return entity
}

func getDocumentsDirectory() -> URL? {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
}
