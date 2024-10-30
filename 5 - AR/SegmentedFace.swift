//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/10/2024.
//
import RealityKit
import SwiftUI

// Step 1: Load the PNG Image from URL
private func loadPNGFromURL(url: URL) -> UIImage? {
    if let data = try? Data(contentsOf: url),
       let uiImage = UIImage(data: data) {
        return uiImage
    } else {
        print("Error loading image from URL: \(url)")
        return nil
    }
}

// Step 2: Create Texture and Aspect Ratio from the PNG
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

// Step 3: Create a 2D Entity with Image
func create2DEntityFromImage(url: URL) -> Entity {
    // Load the PNG image from the URL
    guard let uiImage = loadPNGFromURL(url: url),
          let (texture, aspectRatio) = createTextureFromPNG(image: uiImage) else {
        return Entity() // Return an empty entity if loading fails
    }

    // Adjust the plane dimensions based on the aspect ratio
    let width: Float = 0.5 // Base width
    let height: Float = width / aspectRatio // Height adjusted based on aspect ratio

    // Create a plane mesh to display the image with correct aspect ratio
    let planeMesh = MeshResource.generatePlane(width: width, height: height)

    // Create a material using the PNG texture
    var material = UnlitMaterial()
    material.color = .init(texture: .init(texture!))
    material.opacityThreshold = 0.1 // Ensure transparency is handled
    
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

/// Retrieves the URL of the saved segmented face, assuming it is stored in the temporary directory
func getSegmentedImageURL() -> URL? {
    // Retrieve the URL of the saved segmented image
    // Assuming you stored the URL as a singleton or in a shared manager
    return FileManager.default.temporaryDirectory.appendingPathComponent("segmentedFace.png")
}
