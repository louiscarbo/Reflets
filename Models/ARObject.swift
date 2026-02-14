//
//  ARObject.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 30/10/2024.
//

import SwiftData
import RealityKit
import Foundation
import UIKit
import SwiftUI

// MARK: - Enums

enum ARObjectType: String, Codable, CaseIterable {
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
        self == .text
    }
    
    var hasCustomRatio: Bool {
        self == .cone || self == .cylinder
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

// MARK: - ARObjectProperties

struct ARObjectProperties: Equatable {
    var type: ARObjectType = .sphere
    var color: Color = .yellow
    var metallic: Bool = true
    var text: String = "Hello!"
    var ratio: Float = 2.0
    var opacity: Double = 1.0
    var size: Float = 1.0
    var resizingFactor: Float = 0.5
    var imageURL: URL? = nil
}

// MARK: - ARObject Model

@Model
final class ARObject {
    var id: UUID
    var type: ARObjectType
    
    // Properties flattened from ARObjectProperties
    var red: Double
    var green: Double
    var blue: Double
    
    var isMetallic: Bool
    var text: String
    var ratio: Float
    var opacity: Double
    var size: Float
    var resizingFactor: Float
    
    // UUID string for the image file saved in the document directory
    var imageID: String?
    
    // Position flattened from SIMD3<Float>
    var x: Float
    var y: Float
    var z: Float
    
    // Relationship
    var board: VisionBoard?
    
    init(type: ARObjectType = .sphere,
         color: Color = .yellow,
         isMetallic: Bool = true,
         text: String = "Hello!",
         ratio: Float = 2.0,
         opacity: Double = 1.0,
         size: Float = 1.0,
         resizingFactor: Float = 0.5,
         imageID: String? = nil,
         position: SIMD3<Float> = .zero) {
        
        self.id = UUID()
        self.type = type
        
        // Extract RGB
        if let components = color.cgColor?.components, components.count >= 3 {
             self.red = Double(components[0])
             self.green = Double(components[1])
             self.blue = Double(components[2])
        } else {
             // Fallback
             self.red = 1.0; self.green = 1.0; self.blue = 0.0
        }

        self.isMetallic = isMetallic
        self.text = text
        self.ratio = ratio
        self.opacity = opacity
        self.size = size
        self.resizingFactor = resizingFactor
        self.imageID = imageID
        
        self.x = position.x
        self.y = position.y
        self.z = position.z
    }
    
    convenience init(properties: ARObjectProperties, position: SIMD3<Float>) {
        self.init(
            type: properties.type,
            color: properties.color,
            isMetallic: properties.metallic,
            text: properties.text,
            ratio: properties.ratio,
            opacity: properties.opacity,
            size: properties.size,
            resizingFactor: properties.resizingFactor,
            imageID: nil, // TODO: Handle image persistence from properties.imageURL
            position: position
        )
    }
    
    // MARK: - Computed Properties (Compatibility Layers)
    
    var color: Color {
        get { Color(red: red, green: green, blue: blue) }
        set {
            if let components = newValue.cgColor?.components, components.count >= 3 {
                red = Double(components[0])
                green = Double(components[1])
                blue = Double(components[2])
            }
        }
    }
    
    var position: SIMD3<Float> {
        get { SIMD3(x, y, z) }
        set { x = newValue.x; y = newValue.y; z = newValue.z }
    }
    
    var material: SimpleMaterial {
        SimpleMaterial(
            color: UIColor(color.opacity(opacity)),
            isMetallic: isMetallic
        )
    }
    
    // MARK: - Logic
    
    func generateEntity() -> Entity {
        let entity: Entity
        
        let resizingFactor = self.resizingFactor * 0.4 + 0.01
        
        switch type {
        case .sphere:
            let modelEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: size * resizingFactor))
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .cube:
            let modelEntity = ModelEntity(mesh: MeshResource.generateBox(size: size * resizingFactor))
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .cone:
            let modelEntity = ModelEntity(
                mesh: MeshResource.generateCone(
                    height: ratio * size * resizingFactor,
                    radius: size * resizingFactor
                )
            )
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .cylinder:
            let modelEntity = ModelEntity(
                mesh: MeshResource.generateCylinder(
                    height: ratio * size * resizingFactor,
                    radius: size * resizingFactor
                )
            )
            modelEntity.model?.materials = [material]
            entity = modelEntity
        case .text:
            let modelEntity = ModelEntity(
                mesh: MeshResource.generateText(
                    text,
                    extrusionDepth: 0.05,
                    font: .systemFont(ofSize: 1.0 * CGFloat(size * resizingFactor)),
                    containerFrame: CGRect.zero,
                    alignment: .center,
                    lineBreakMode: .byWordWrapping
                )
            )
            modelEntity.model?.materials = [material]
            
            let bounds = modelEntity.visualBounds(relativeTo: nil)
            let centerOffset = bounds.center
            
            let transformMatrix = Transform(
                translation: SIMD3(-centerOffset.x, -centerOffset.y, 0)
            ).matrix
            
            modelEntity.setTransformMatrix(transformMatrix, relativeTo: nil)
            
            entity = modelEntity
        case .image:
            if let id = imageID, let url = getDocumentsDirectory()?.appendingPathComponent(id).appendingPathExtension("png") {
                entity = create2DEntityFromImage(
                    url: url,
                    size: size * resizingFactor * 3.5,
                    opacity: opacity
                )
            } else {
                entity = Entity()
            }
        }

        entity.position = position
        return entity
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}

// MARK: - Helper Functions

private func loadPNGFromURL(url: URL) -> UIImage? {
    if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
        return uiImage
    } else {
        print("Error loading image from URL: \(url)")
        return nil
    }
}

private func createTextureFromPNG(image: UIImage) -> (TextureResource?, Float)? {
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
    entity.position = [0, 0, -1] 

    return entity
}

// MARK: - CustomObjectPreview struct

struct CustomObjectPreview: Hashable {
    var preview: UIImage
    var url: URL
}
