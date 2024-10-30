//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 15/10/2024.
//

import AVFoundation
import UIKit
import Combine
import Vision

class SelfieViewModel: NSObject, ObservableObject {
    var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var image: UIImage?
    
    func setupCamera() {
        session.beginConfiguration()
        
        session.sessionPreset = .photo
        
        // Add the front camera as the input device
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get front camera")
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            print("Failed to create or add input")
            return
        }
        
        session.addInput(input)
        
        // Add the photo output
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        
        // Ensure the session starts running
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            print("Session started running: \(self.session.isRunning)")
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - Photo Capture Delegate
extension SelfieViewModel: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let data = photo.fileDataRepresentation(),
              let capturedUIImage = UIImage(data: data) else { return }
        
        // Flip the captured image horizontally
        guard let flippedImage = capturedUIImage.flippedHorizontally() else { return }

        // Remove the background from the flipped image (the captured image)
        removeBackground(from: flippedImage)
    }
}

// MARK: - Symmetry function
extension UIImage {
    func flippedHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Flip the image horizontally
        context.translateBy(x: self.size.width, y: 0)
        context.scaleBy(x: -1.0, y: 1.0)
        
        // Draw the original image in the flipped context
        self.draw(in: CGRect(origin: .zero, size: self.size))
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flippedImage
    }
}

// MARK: - Vision Segmentation Functions
extension SelfieViewModel {
    
    func removeBackground(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .accurate
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
                if let maskPixelBuffer = request.results?.first?.pixelBuffer {
                    let maskedImage = self.applyMask(maskPixelBuffer, to: image)
                    DispatchQueue.main.async {
                        self.image = maskedImage
                    }
                }
            } catch {
                print("Error processing image: \(error)")
            }
        }
    }
    
    func applyMask(_ maskPixelBuffer: CVPixelBuffer, to image: UIImage) -> UIImage? {
        // Convert the pixel buffer mask into a CGImage
        let maskCIImage = CIImage(cvPixelBuffer: maskPixelBuffer)
        
        // Create a CIImage from the original UIImage
        guard let cgImage = image.cgImage else { return nil }
        let originalCIImage = CIImage(cgImage: cgImage)
        
        // Scale the mask to match the original image's size
        let originalSize = originalCIImage.extent.size
        let scaledMask = maskCIImage.transformed(by: CGAffineTransform(scaleX: originalSize.width / maskCIImage.extent.width, y: originalSize.height / maskCIImage.extent.height))
        
        // Create a new mask from the scaled mask using the original image dimensions
        let filter = CIFilter(name: "CIBlendWithMask")
        filter?.setValue(originalCIImage, forKey: kCIInputImageKey)
        filter?.setValue(scaledMask, forKey: kCIInputMaskImageKey)
        
        // Apply the filter
        guard let outputCIImage = filter?.outputImage else { return nil }
        
        // Convert the CIImage back to a UIImage
        let context = CIContext()
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return nil }
        
        let segmentedUIIMage = UIImage(cgImage: outputCGImage)
        saveSegmentedImage(segmentedUIIMage)
        
        return segmentedUIIMage
    }

}

extension SelfieViewModel {
    func saveSegmentedImage(_ image: UIImage) {
        // Access the temporary directory
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent("segmentedFace.png")

        do {
            // Convert the image to PNG data and write it to the file URL
            if let data = image.pngData() {
                try data.write(to: fileURL)
                print("Segmented image saved to temporary directory: \(fileURL)")
                return
            }
        } catch {
            print("Error saving image: \(error)")
        }
        return
    }
}
