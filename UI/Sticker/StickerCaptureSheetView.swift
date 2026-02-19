//
//  StickerCaptureSheetView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 23/12/2024.
//

import SwiftUI
import PhotosUI
import Vision
import SwiftData

struct StickerCaptureSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var captureState: CaptureState = .selecting
    @State private var showCameraView = false
    @State private var photoPickerItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            Text("New Sticker")
                .font(.title)
                .fontWeight(.semibold)
                .fontWidth(.expanded)
            
            switch captureState {
            case .selecting:
                ImageSelectionView(
                    photoPickerItem: $photoPickerItem,
                    onPhotoSelected: loadImageFromPicker,
                    onTakePhoto: { showCameraView = true }
                )
                
            case .segmenting(let image):
                SegmentationLoadingView()
                    .task {
                        await performSegmentation(on: image)
                    }
                
            case .reviewing(let image, let backgroundRemoved):
                ImageApprovalView(
                    image: image,
                    backgroundRemoved: backgroundRemoved,
                    onReset: resetCapture,
                    onApprove: { addTostickers(imageData: $0) }
                )
                
            case .error:
                ErrorView()
                    .task {
                        try? await Task.sleep(for: .seconds(3))
                        dismiss()
                    }
            }
        }
        .padding(25)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showCameraView) {
            CameraView(onImageCaptured: handleCapturedImage)
        }
    }
    
    private func loadImageFromPicker() {
        guard let photoPickerItem else { return }
        Task {
            if let data = try? await photoPickerItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                handleCapturedImage(image)
            }
        }
    }
    
    private func handleCapturedImage(_ image: UIImage) {
        captureState = .segmenting(image: image)
    }
    
    private func performSegmentation(on image: UIImage) async {
        // Try segmentation with timeout
        let segmentedImage = await withTimeout(seconds: 3) {
            await ImageProcessingService.getSegmentedImage(from: image)
        }
        
        if let segmentedImage {
            captureState = .reviewing(image: segmentedImage, backgroundRemoved: true)
        } else {
            captureState = .reviewing(image: image, backgroundRemoved: false)
        }
    }
    
    private func resetCapture() {
        captureState = .selecting
        photoPickerItem = nil
    }
    
    private func addTostickers(imageData: Data) {
        let thumbnailData = ImageProcessingService.makeThumbnailData(from: imageData)
        let newObject = Sticker(imageData: imageData, thumbnailData: thumbnailData)
        modelContext.insert(newObject)
        dismiss()
    }
    
    private func withTimeout<T>(seconds: Double, operation: @escaping () async -> T?) async -> T? {
        await withTaskGroup(of: T?.self) { group in
            group.addTask {
                await operation()
            }
            group.addTask {
                try? await Task.sleep(for: .seconds(seconds))
                return nil
            }
            
            if let result = await group.next() {
                group.cancelAll()
                return result
            }
            return nil
        }
    }
}

// MARK: - Capture State

private enum CaptureState {
    case selecting
    case segmenting(image: UIImage)
    case reviewing(image: UIImage, backgroundRemoved: Bool)
    case error
}

#Preview {
    ARControlsView(session: .init(board: .init()))
        .sheet(isPresented: .constant(true)) {
            StickerCaptureSheetView()
        }
}

// MARK: - Image Selection View

private struct ImageSelectionView: View {
    @Binding var photoPickerItem: PhotosPickerItem?
    let onPhotoSelected: () -> Void
    let onTakePhoto: () -> Void
    
    var body: some View {
        VStack {
            PhotosPicker("Choose Photo", selection: $photoPickerItem, matching: .images)
                .onChange(of: photoPickerItem) {
                    onPhotoSelected()
                }
                .buttonStyle(IntentionButton(horizontalPadding: 30))
            
            Button("Take Photo", action: onTakePhoto)
                .buttonStyle(IntentionButton(horizontalPadding: 30))
        }
    }
}

// MARK: - Segmentation Loading View

private struct SegmentationLoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
}

// MARK: - Error View

private struct ErrorView: View {
    var body: some View {
        Text("An error occurred. Please try again.")
    }
}

// MARK: - Camera View

private struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void

        init(onImageCaptured: @escaping (UIImage) -> Void) {
            self.onImageCaptured = onImageCaptured
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: ImageApprovalView

private struct ImageApprovalView: View {
    let image: UIImage
    let backgroundRemoved: Bool
    let onReset: () -> Void
    let onApprove: (Data) -> Void
    
    @State private var rotationAngle: Double = 0
    @State private var isProcessing = false
    @State private var hintRotation: Double = 0
    
    var body: some View {
        VStack {
            Rectangle()
                .foregroundStyle(Color.clear)
                .overlay {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(rotationAngle + hintRotation))
                }
                .onTapGesture {
                    withAnimation(.bouncy) {
                        rotationAngle += 90
                    }
                }
                .task {
                    try? await Task.sleep(for: .seconds(0.5))
                    while !Task.isCancelled {
                        withAnimation(.bouncy(duration: 0.2)) {
                            hintRotation = 5
                        }
                        try? await Task.sleep(for: .milliseconds(200))
                        withAnimation(.bouncy(duration: 0.2)) {
                            hintRotation = 0
                        }
                        try? await Task.sleep(for: .milliseconds(200))
                        withAnimation(.bouncy(duration: 0.2)) {
                            hintRotation = 5
                        }
                        try? await Task.sleep(for: .milliseconds(200))
                        withAnimation(.bouncy(duration: 0.2)) {
                            hintRotation = 0
                        }
                        try? await Task.sleep(for: .seconds(5))
                    }
                }
                .aspectRatio(contentMode: .fit)
            
            Text("Tap the image to rotate it.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if !backgroundRemoved {
                Text("The background could not be removed from this image. Do you still want to add it?")
            }
            
            VStack {
                Button("Choose another photo", action: onReset)
                    .buttonStyle(IntentionButton(horizontalPadding: 30))
                    .disabled(isProcessing)
                
                Button("Add") {
                    isProcessing = true
                    Task {
                        let imageData = await Task.detached(priority: .userInitiated) {
                            await ImageProcessingService.processImageForStorage(image: image, degrees: rotationAngle)
                        }.value
                        
                        await MainActor.run {
                            if let imageData {
                                onApprove(imageData)
                            }
                            isProcessing = false
                        }
                    }
                }
                .buttonStyle(IntentionButton(horizontalPadding: 30))
                .disabled(isProcessing)
            }
            .font(.title2)
        }
    }
}
