//
//  ObjectCaptureFunctions.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 23/12/2024.
//

import UIKit
import Vision

func getSegmentedImage(from image: UIImage?) async -> UIImage? {
    guard let cgImage = image?.cgImage else {
        return nil
    }
    do {
        // Perform the request on a background thread
        let requestResults = try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let handler = VNImageRequestHandler(cgImage: cgImage)
                    let request = VNGenerateForegroundInstanceMaskRequest()
                    try handler.perform([request])
                    continuation.resume(returning: request.results)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        // Check for results
        guard let results = requestResults, let result = results.first else {
            print("No segmentation results found.")
            return nil
        }

        // Generate the masked image directly
        let outputPixelBuffer = try result.generateMaskedImage(
            ofInstances: result.allInstances,
            from: VNImageRequestHandler(cgImage: cgImage),
            croppedToInstancesExtent: true
        )

        // Convert the CVPixelBuffer to a UIImage
        guard let uiImageOutput = pixelBufferToUIImage(pixelBuffer: outputPixelBuffer) else {
            print("Error converting pixel buffer to UIImage.")
            return nil
        }
        
        return uiImageOutput
    } catch {
        print("Error during segmentation: \(error.localizedDescription)")
        return nil
    }
}

 func pixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
    // Create a CIImage from the pixel buffer
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

    // Render the CIImage to a UIImage
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    return UIImage(cgImage: cgImage)
}


func rotateImage90Degrees(image: UIImage) -> UIImage {
    // Define the new size: width becomes height, height becomes width
    let size = CGSize(width: image.size.height, height: image.size.width)
    
    // Begin a new image context
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    defer { UIGraphicsEndImageContext() }
    
    guard let context = UIGraphicsGetCurrentContext() else {
        print("Failed to get graphics context")
        return image
    }
    
    // Move origin to the center of the canvas
    context.translateBy(x: size.width / 2, y: size.height / 2)
    
    // Rotate context by 90 degrees (π/2 radians)
    context.rotate(by: .pi / 2)
    
    // Draw the original image into the context
    context.scaleBy(x: 1.0, y: -1.0) // Flip vertically to match UIKit coordinate system
    let rect = CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height)
    context.draw(image.cgImage!, in: rect)
    
    // Get the rotated image
    if let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
        return rotatedImage
    } else {
        print("Failed to get rotated image from context")
        return image
    }
}
