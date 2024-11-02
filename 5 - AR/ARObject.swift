//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 30/10/2024.
//

import RealityKit
import Foundation

enum SelectedType {
    case sphere, cube, cone, cylinder, text, image
}

enum ARObjectType: Hashable {
    case sphere(radius: Float)
    case cube(size: Float)
    case cone(radius: Float, height: Float)
    case cylinder(radius: Float, height: Float)
    case text(content: String)
    case image(url: URL)
    
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
    
    func generateEntity() -> ModelEntity {
        let entity: ModelEntity
        switch type {
        case .sphere(let radius):
            entity = ModelEntity(mesh: MeshResource.generateSphere(radius: radius))
        case .cube(let size):
            entity = ModelEntity(mesh: MeshResource.generateBox(size: size))
        case .cone(let radius, let height):
            entity = ModelEntity(mesh: MeshResource.generateCone(height: height, radius: radius))
        case .cylinder(let radius, let height):
            entity = ModelEntity(mesh: MeshResource.generateCylinder(height: height, radius: radius))
        case .text(let content):
            entity = ModelEntity(mesh: MeshResource.generateText(content, extrusionDepth: 0.05, font: .systemFont(ofSize: 0.1), containerFrame: CGRect.zero, alignment: .center, lineBreakMode: .byWordWrapping))
        case .image(let url):
            // TODO: Load the image and integrate it as a texture
            entity = ModelEntity()
        }
        
        entity.model?.materials = [color]
        entity.position = position
        return entity
    }
}
