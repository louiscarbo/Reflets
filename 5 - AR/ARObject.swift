//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 30/10/2024.
//

import RealityKit
import Foundation
import UIKit

enum SelectedType {
    case sphere, cube, cone, cylinder, text, image
    
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

enum ARObjectType: Hashable {
    case sphere(radius: Float)
    case cube(size: Float)
    case cone(radius: Float, height: Float)
    case cylinder(radius: Float, height: Float)
    case text(content: String, size: Float)
    case image(url: URL?, size: Float)
    
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
}

struct ARObject {
    var type: ARObjectType
    var color: SimpleMaterial
    var position: SIMD3<Float>
    var imageOpacity: Float = 1.0
    
    func generateEntity() -> Entity {
        let entity: Entity
        switch type {
        case .sphere(let radius):
            let modelEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: radius))
            modelEntity.model?.materials = [color]
            entity = modelEntity
        case .cube(let size):
            let modelEntity = ModelEntity(mesh: MeshResource.generateBox(size: size))
            modelEntity.model?.materials = [color]
            entity = modelEntity
        case .cone(let radius, let height):
            let modelEntity = ModelEntity(mesh: MeshResource.generateCone(height: height, radius: radius))
            modelEntity.model?.materials = [color]
            entity = modelEntity
        case .cylinder(let radius, let height):
            let modelEntity = ModelEntity(mesh: MeshResource.generateCylinder(height: height, radius: radius))
            modelEntity.model?.materials = [color]
            entity = modelEntity
        case .text(let content, let size):
            let modelEntity = ModelEntity(
                mesh: MeshResource.generateText(
                    content,
                    extrusionDepth: 0.05,
                    font: .systemFont(ofSize: 0.1 * CGFloat(size)),
                    containerFrame: CGRect.zero,
                    alignment: .center,
                    lineBreakMode: .byWordWrapping
                )
            )
            modelEntity.model?.materials = [color]
            entity = modelEntity
        case .image(let url, let size):
            // For images, create a 2D entity
            if let url = url {
                entity = create2DEntityFromImage(url: url, size: size, opacity: imageOpacity)
            } else {
                entity = Entity()
            }
        }

        // Apply position
        entity.position = position

        return entity
    }
}

struct CustomObjectPreview: Hashable {
    var preview: UIImage
    var url: URL
}

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

func create2DEntityFromImage(url: URL, size: Float, opacity: Float = 1.0) -> Entity {
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
