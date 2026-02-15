//
//  ImageProcessingService.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 23/12/2024.
//

import UIKit
import Vision

/// A service dedicated to image processing and Vision tasks.
enum ImageProcessingService {
    
    /// Shared CIContext to avoid expensive recreation on every call.
    private static let ciContext = CIContext()
    
    /// Segments the foreground subject from the background using Vision.
    static func getSegmentedImage(from image: UIImage?) async -> UIImage? {
        guard let cgImage = image?.cgImage else {
            return nil
        }
        
        return await Task.detached(priority: .userInitiated) {
            do {
                let handler = VNImageRequestHandler(cgImage: cgImage)
                let request = VNGenerateForegroundInstanceMaskRequest()
                try handler.perform([request])
                
                guard let result = request.results?.first else {
                    print("No segmentation results found.")
                    return nil
                }
                
                let outputPixelBuffer = try result.generateMaskedImage(
                    ofInstances: result.allInstances,
                    from: VNImageRequestHandler(cgImage: cgImage),
                    croppedToInstancesExtent: true
                )
                
                return pixelBufferToUIImage(pixelBuffer: outputPixelBuffer)
            } catch {
                print("Error during segmentation: \(error.localizedDescription)")
                return nil
            }
        }.value
    }
    
    /// Converts a CVPixelBuffer to a UIImage using a cached CIContext.
    static func pixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    /// Rotates an image 90 degrees clockwise using UIGraphicsImageRenderer.
    static func rotateImage90Degrees(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.height, height: image.size.width)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { context in
            let cgContext = context.cgContext
            
            cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            cgContext.rotate(by: .pi / 2)
            
            image.draw(in: CGRect(
                x: -image.size.width / 2,
                y: -image.size.height / 2,
                width: image.size.width,
                height: image.size.height
            ))
        }
    }
}
