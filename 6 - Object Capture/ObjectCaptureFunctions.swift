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

func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
    guard let data = image.pngData() else { return nil }
    let temporaryDirectory = FileManager.default.temporaryDirectory
    let fileURL = temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("png")
    
    do {
        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("Error saving image to temporary directory: \(error.localizedDescription)")
        return nil
    }
}

func fetchSegmentedImagesFromTemporaryDirectory() -> [CustomObjectPreview] {
    let temporaryDirectory = FileManager.default.temporaryDirectory
    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil)
        
        return fileURLs
            .filter { $0.pathExtension == "png" }
            .compactMap { url -> CustomObjectPreview? in
                if let image = UIImage(contentsOfFile: url.path),
                   let resizedImage = resizeImage(image, to: CGSize(width: 50, height: 50)) {
                    return CustomObjectPreview(preview: resizedImage, url: url)
                } else {
                    return nil
                }
            }
    } catch {
        print("Error fetching images: \(error.localizedDescription)")
        return []
    }
}

func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
    let renderer = UIGraphicsImageRenderer(size: size)
    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: size))
    }
}

func deleteAllSegmentedPNGs() {
    let temporaryDirectory = FileManager.default.temporaryDirectory
    
    do {
        // Get all files in the temporary directory
        let fileURLs = try FileManager.default.contentsOfDirectory(at: temporaryDirectory, includingPropertiesForKeys: nil)
        
        // Filter for PNG files
        let pngFiles = fileURLs.filter { $0.pathExtension == "png" }
        
        // Delete each PNG file
        for fileURL in pngFiles {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        print("All segmented PNGs have been deleted.")
    } catch {
        print("Error deleting PNGs: \(error.localizedDescription)")
    }
}

func rotateImage90Degrees(image: UIImage) -> UIImage? {
    let size = CGSize(width: image.size.height, height: image.size.width) // Swap dimensions for 90 degrees
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    defer { UIGraphicsEndImageContext() }

    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    // Move origin to the center of the canvas
    context.translateBy(x: size.width / 2, y: size.height / 2)

    // Rotate context 90 degrees (π/2 radians)
    context.rotate(by: .pi / 2)

    // Draw the image into the context
    context.scaleBy(x: 1.0, y: -1.0) // Correct the coordinate system
    let rect = CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height)
    context.draw(image.cgImage!, in: rect)

    // Get the rotated image
    return UIGraphicsGetImageFromCurrentImageContext()
}

func logTemporaryDirectoryContents() {
    let tempDirectory = FileManager.default.temporaryDirectory
    do {
        let contents = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        print("Contents of Temporary Directory:")
        for file in contents {
            print("File: \(file.lastPathComponent)")
        }
    } catch {
        print("Error reading temporary directory: \(error.localizedDescription)")
    }
}
