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
    @State private var selectedImage: UIImage?
    @State private var selectedImageRotationAngle: CGFloat = 0

    @State private var segmentedImage: UIImage?
    @State private var segmentedImageRotationAngle: CGFloat = 0
    
    @State private var showCameraView = false
    @State private var hasTimedOut = false
    
    @Environment(\.dismiss) var dismiss
    
    var segmentedImages: [UIImage] {
        fetchSegmentedImagesFromTemporaryDirectory().map{ $0.preview }
    }

    var body: some View {
        VStack {
            Text("New Custom Object")
                .font(.title)
                .fontWeight(.semibold)
                .fontWidth(.expanded)
                
            if selectedImage == nil {
                HStack {
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
                    var rotatedSelectedImage = selectedImage
                    
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .overlay {
                            Image(uiImage: selectedImage!)
                                .resizable()
                                .scaledToFit()
                                .rotationEffect(Angle(degrees: Double(selectedImageRotationAngle)))
                                .onTapGesture {
                                    withAnimation {
                                        selectedImageRotationAngle += 90
                                    }
                                    rotatedSelectedImage = rotateImage90Degrees(image: rotatedSelectedImage!)
                                }
                        }
                    .aspectRatio(contentMode: .fit)
                    
                    Text("The background cannot be removed. Do you still want to add this image to your custom objects?")
                    HStack {
                        Button("Choose another photo") {
                            hasTimedOut = false
                            selectedImage = nil
                            segmentedImage = nil
                        }
                        .buttonStyle(IntentionButton(horizontalPadding: 30))
                        Button("Add") {
                            if saveImageToTemporaryDirectory(image: rotatedSelectedImage!) != nil {
                                dismiss()
                            }
                        }
                        .buttonStyle(IntentionButton(horizontalPadding: 30))
                    }
                } else {
                    var rotatedSegmentedImage = segmentedImage
                    Rectangle()
                        .foregroundStyle(Color.clear)
                        .overlay {
                            Image(uiImage: segmentedImage!)
                                .resizable()
                                .scaledToFit()
                                .onTapGesture {
                                    withAnimation {
                                        segmentedImageRotationAngle += 90
                                    }
                                    rotatedSegmentedImage = rotateImage90Degrees(image: rotatedSegmentedImage!)
                                }
                                .rotationEffect(Angle(degrees: Double(segmentedImageRotationAngle)))
                        }
                        .aspectRatio(contentMode: .fit)
                    HStack {
                        Button("Choose another photo") {
                            hasTimedOut = false
                            selectedImage = nil
                            segmentedImage = nil
                        }
                        .buttonStyle(IntentionButton(horizontalPadding: 30))
                        Button("Add") {
                            if saveImageToTemporaryDirectory(image: rotatedSegmentedImage!) != nil {
                                dismiss()
                            }
                        }
                        .buttonStyle(IntentionButton(horizontalPadding: 30))
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
            showReflectoHelp: .constant(false),
            showObjectsCatalog: $isPresented,
            artworkIsDone: .constant(false),
            shouldAddObject: .constant(false),
            showCustomizationSheet: .constant(false),
            arObjects: .constant([]),
            sliderValue: .constant(0.8)
        )
        .sheet(isPresented: .constant(true)) {
            ObjectsCatalogSheetView(selectedType: .constant(.cube))
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
