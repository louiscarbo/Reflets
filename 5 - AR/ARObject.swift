//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 30/10/2024.
//

import RealityKit
import Foundation
import UIKit
import SwiftUI

// MARK: ARObjectType enum
enum ARObjectType {
    case sphere, cube, cone, cylinder, text, image
    
    var hasCustomColor: Bool {
        switch self {
        case .sphere, .cube, .cone, .cylinder, .text:
            return true
        default:
            return false
        }
    }
    
    var hasCustomText: Bool {
        switch self {
        case .text:
            return true
        default:
            return false
        }
    }
    
    var hasCustomRatio: Bool {
        switch self {
        case .cone, .cylinder:
            return true
        default:
            return false
        }
    }
    
    var SFSymbolName: String {
        switch self {
        case .cone: return "cone"
        case .sphere: return "rotate.3d"
        case .cube: return "cube"
        case .cylinder: return "cylinder"
        case .text: return "textformat"
        default: return "questionmark"
        }
    }
}

// MARK: ARObjectProperties struct
struct ARObjectProperties: Equatable {
    var type: ARObjectType = .sphere
    var color: Color = .yellow
    var metallic: Bool = true
    var text: String = "Hello!"
    var ratio: Float = 2.0
    var opacity: Double = 1.0
    var size: Float = 1.0 // Radius or length depending on the object type
    var resizingFactor: Float = 0.5
    var imageURL: URL? = nil
}

// MARK: ARObject struct
struct ARObject: Equatable {
    var properties: ARObjectProperties
    var position: SIMD3<Float>
    
    var material: SimpleMaterial {
        SimpleMaterial(
            color: UIColor(properties.color.opacity(properties.opacity)),
            isMetallic: properties.metallic
        )
    }
    
    func generateEntity() -> Entity {
        let entity: Entity
        
        let resizingFactor = properties.resizingFactor * 0.4 + 0.01
        
        // Create the entity based on the object type
        switch properties.type {
        case .sphere:
            let modelEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: properties.size * resizingFactor))
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .cube:
            let modelEntity = ModelEntity(mesh: MeshResource.generateBox(size: properties.size * resizingFactor))
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .cone:
            let modelEntity = ModelEntity(
                mesh: MeshResource.generateCone(
                    height: properties.ratio * properties.size * resizingFactor,
                    radius: properties.size * resizingFactor
                )
            )
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .cylinder:
            let modelEntity = ModelEntity(
                mesh: MeshResource.generateCylinder(
                    height: properties.ratio * properties.size * resizingFactor,
                    radius: properties.size * resizingFactor
                )
            )
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .text:
            let modelEntity = ModelEntity(
                mesh: MeshResource.generateText(
                    properties.text,
                    extrusionDepth: 0.05,
                    font: .systemFont(ofSize: 1.0 * CGFloat(properties.size * resizingFactor)),
                    containerFrame: CGRect.zero,
                    alignment: .center,
                    lineBreakMode: .byWordWrapping
                )
            )
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .image:
            if let url = properties.imageURL {
                entity = create2DEntityFromImage(
                    url: url,
                    size: properties.size * resizingFactor * 3.5,
                    opacity: properties.opacity
                )
            } else {
                entity = Entity()
            }
        }

        // Apply position
        entity.position = position

        return entity
    }
}

// MARK: CustomObjectPreview struct
struct CustomObjectPreview: Hashable {
    var preview: UIImage
    var url: URL
}

// MARK: Helper functions
private func loadPNGFromURL(url: URL) -> UIImage? {
    if let data = try? Data(contentsOf: url),
       let uiImage = UIImage(data: data) {
        return uiImage
    } else {
        print("Error loading image from URL: \(url)")
        return nil
    }
}

private func createTextureFromPNG(image: UIImage) -> (TextureResource?, Float)? {
    // Get the aspect ratio of the image
    let aspectRatio = Float(image.size.width / image.size.height)
    
    // Convert UIImage to CGImage
    guard let cgImage = image.cgImage else { return nil }
    
    do {
        // Create TextureResource from CGImage
        let texture = try TextureResource(image: cgImage, options: .init(semantic: .normal))
        return (texture, aspectRatio)
    } catch {
        print("Error creating texture from image: \(error)")
        return nil
    }
}

func create2DEntityFromImage(url: URL, size: Float, opacity: Double = 1.0) -> Entity {
    // Load the PNG image from the URL
    guard let uiImage = loadPNGFromURL(url: url),
          let (texture, aspectRatio) = createTextureFromPNG(image: uiImage) else {
        return Entity() // Return an empty entity if loading fails
    }

    // Adjust the plane dimensions based on the aspect ratio
    let width: Float = 0.5 * size // Base width
    let height: Float = width / aspectRatio // Height adjusted based on aspect ratio

    // Create a plane mesh to display the image with correct aspect ratio
    let planeMesh = MeshResource.generatePlane(width: width, height: height)

    // Create a material using the PNG texture
    var material = UnlitMaterial()
    material.color = .init(tint: UIColor.white.withAlphaComponent(CGFloat(opacity)), texture: .init(texture!))
    material.opacityThreshold = 0.01 // Ensure transparency is handled
    
    // Make the material double-sided
    material.faceCulling = .none

    // Create a ModelComponent with the mesh and material
    let modelComponent = ModelComponent(mesh: planeMesh, materials: [material])

    // Create and return the entity
    let entity = ModelEntity()
    entity.components.set(modelComponent)
    
    entity.position = [0, 0, -1]

    return entity
}
