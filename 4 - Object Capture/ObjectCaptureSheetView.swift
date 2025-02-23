//
//  ObjectCaptureView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 23/12/2024.
//

import SwiftUI
import PhotosUI
import Vision

struct ObjectCaptureSheetView: View {
    @Binding var shouldUpdateCustomObjects: Bool
    
    @State private var selectedImage: UIImage?
    @State private var selectedImageRotationAngle: CGFloat = 0

    @State private var segmentedImage: UIImage?
    @State private var segmentedImageRotationAngle: CGFloat = 0
    
    @State private var showCameraView = false
    @State private var hasTimedOut = false
    
    @Environment(\.dismiss) var dismiss

    // MARK: - ObjectCaptureSheetView
    var body: some View {
        VStack {
            Text("New Custom Object")
                .font(.title)
                .fontWeight(.semibold)
                .fontWidth(.expanded)
                
            if selectedImage == nil {
                VStack {
                    PhotosPicker("Choose Photo", selection: $photoPickerItem, matching: .images)
                        .onChange(of: photoPickerItem) {
                            loadImageFromPicker()
                        }
                        .buttonStyle(IntentionButton(horizontalPadding: 30))
                    
                    Button("Take Photo") {
                        showCameraView = true
                    }
                    .buttonStyle(IntentionButton(horizontalPadding: 30))
                }
            } else {
                if segmentedImage == nil && !hasTimedOut {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                if segmentedImage == nil {
                                    hasTimedOut = true
                                }
                            }
                        }
                } else if hasTimedOut {
                    if let selectedImage = selectedImage {
                        ImageApprovalView(
                            image: selectedImage,
                            rotatedImage: selectedImage,
                            imageHasNotBeenSegmented: true,
                            selectedImage: $selectedImage,
                            segmentedImage: $segmentedImage,
                            shouldUpdateCustomObjects: $shouldUpdateCustomObjects
                        )
                    } else {
                        Text("An error occured. Please try again.")
                            .onAppear{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    dismiss()
                                }
                            }
                    }
                } else {
                    if let segmentedImage = segmentedImage {
                        ImageApprovalView(
                            image: segmentedImage,
                            rotatedImage: segmentedImage,
                            selectedImage: $selectedImage,
                            segmentedImage: $segmentedImage,
                            shouldUpdateCustomObjects: $shouldUpdateCustomObjects
                        )
                    } else {
                        Text("An error occured. Please try again.")
                            .onAppear{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    dismiss()
                                }
                            }
                    }
                }
            }
        }
        .padding(25)
        .presentationBackground(.thinMaterial)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(40.0)
        .sheet(isPresented: $showCameraView) {
            CameraView(selectedImage: $selectedImage)
                .background {
                    Color.black.ignoresSafeArea()
                }
        }
        .onChange(of: selectedImage) {
            Task {
                segmentedImage = await getSegmentedImage(from: selectedImage)
            }
        }
    }

    // Image picker state and loader
    @State private var photoPickerItem: PhotosPickerItem?

    // MARK: - Image Loading Functions
    private func loadImageFromPicker() {
        guard let photoPickerItem else { return }
        Task {
            if let data = try? await photoPickerItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false;
    @Previewable @State var textInput = "Hello World!";
    @Previewable @State var showCaptureView = false;
    
    ZStack {
        Image("previewImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ARControlsView(
            artworkIsDone: .constant(false),
            arObjects: .constant([]),
            arObjectProperties: .constant(ARObjectProperties())
        )
        .sheet(isPresented: .constant(true)) {
            ObjectsCatalogSheetView(selectedType: .constant(.cube), imageURL: .constant(nil))
        }
    }
}

// MARK: CameraView
struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: ImageApprovalView
struct ImageApprovalView: View {
    @State var image: UIImage
    @State var rotatedImage: UIImage
    @State var imageHasNotBeenSegmented = false
    
    @Binding var selectedImage: UIImage?
    @Binding var segmentedImage: UIImage?
    @Binding var shouldUpdateCustomObjects: Bool
    
    @State private var imageRotationAngle: CGFloat = 0
    @State private var hasTimedOut = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Rectangle()
                .foregroundStyle(Color.clear)
                .overlay {
                    Image(uiImage: rotatedImage)
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    print("Before rotationEffect: \(imageRotationAngle) degrees")
                    
                    rotatedImage = rotateImage90Degrees(image: rotatedImage)
                    
                    print("After rotateImage90Degrees")
                    
                    withAnimation {
                        imageRotationAngle -= 90
                    }
                    
                    print("After animation update: \(imageRotationAngle) degrees")
                }
                .aspectRatio(contentMode: .fit)
            Text("Tap the image to rotate it.")
            if imageHasNotBeenSegmented {
                Text("The background could not be removed from this image. Do you still want to add it?")
                
            }
            VStack {
                Button("Choose another photo") {
                    hasTimedOut = false
                    selectedImage = nil
                    segmentedImage = nil
                }
                .buttonStyle(IntentionButton(horizontalPadding: 30))
                Button("Add") {
                    addToCustomObjects(image: rotatedImage)
                }
                .buttonStyle(IntentionButton(horizontalPadding: 30))
            }
        }
    }
    
    private func addToCustomObjects(image: UIImage) {
        if saveImageToTemporaryDirectory(image: image) != nil {
            dismiss()
            shouldUpdateCustomObjects = true
        }
    }
}
