//
//  ImageProcessingService.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 23/12/2024.
//

import UIKit
import Vision

enum ImageProcessingService {
    
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
    
    /// Rotates an image by a specific number of degrees.
    static func rotateImage(image: UIImage, degrees: Double) -> UIImage {
        let normalizedDegrees = degrees.truncatingRemainder(dividingBy: 360)
        if abs(normalizedDegrees) < 0.1 { return image }
        
        let radians = degrees * .pi / 180
        
        let transform = CGAffineTransform(rotationAngle: radians)
        let newRect = CGRect(origin: .zero, size: image.size).applying(transform)
        let newSize = newRect.size
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { context in
            let cgContext = context.cgContext
            
            cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            cgContext.rotate(by: radians)
            
            image.draw(in: CGRect(
                x: -image.size.width / 2,
                y: -image.size.height / 2,
                width: image.size.width,
                height: image.size.height
            ))
        }
    }
    
    /// Rotates the image and converts it to PNG Data for storage.
    static func processImageForStorage(image: UIImage, degrees: Double) -> Data? {
        let rotatedImage = rotateImage(image: image, degrees: degrees)
        return rotatedImage.pngData()
    }
}
