//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI
import SwiftData

struct ObjectsCatalogSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    @Binding var selectedType: ARObjectType
    @Binding var selectedCustomObject: CustomObject?
    
    @State private var availableTypes: [ARObjectType] = [.sphere, .cube, .cone, .cylinder, .text]
    
    @State private var showObjectCaptureSheet: Bool = false
    
    @Query(sort: \CustomObject.createdAt, order: .reverse) private var customObjects: [CustomObject]
    
    var body: some View {
        let simpleShapesColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
        let customObjectsColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
        
        VStack {
            ScrollView {
                Text("Objects Catalog")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                
                VStack(alignment: .leading) {
                    Divider()
                    
                    Text("Simple Shapes")
                        .fontWidth(.expanded)
                        .font(.title2)
                    
                    LazyVGrid(columns: simpleShapesColumns) {
                        ForEach(availableTypes, id: \.self) { type in
                            Button {
                                dismiss()
                                hapticFeedback.notificationOccurred(.success)
                                selectedType = type
                            } label: {
                                Image(systemName: type.SFSymbolName)
                            }
                            .buttonStyle(SFSymbolButtonStyle())
                            .padding(.bottom, 10)
                        }
                    }
                    
                    Divider()
                    
                    Text("Custom Objects")
                        .fontWidth(.expanded)
                        .font(.title2)
                    
                    LazyVGrid(columns: customObjectsColumns) {
                        ForEach(customObjects) { object in
                            AsyncThumbnailButton(
                                object: object,
                                onSelect: {
                                    dismiss()
                                    hapticFeedback.notificationOccurred(.success)
                                    selectedType = .image
                                    selectedCustomObject = object
                                }
                            )
                        }
                        Button {
                            showObjectCaptureSheet = true
                            
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(SFSymbolButtonStyle(symbolSize: 43))
                        .sheet(isPresented: $showObjectCaptureSheet) {
                            ObjectCaptureSheetView()
                        }
                    } // LazyVGrid
                }
            }
            .padding(25)
        }
        .ignoresSafeArea()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    @Previewable @State var isPresented = false;
    @Previewable @State var textInput = "Hello World!";
    
    ZStack {
        Image("previewImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ARControlsView(session: .init(board: .init()))
            .sheet(isPresented: $isPresented) {
                ObjectsCatalogSheetView(selectedType: .constant(.cube), selectedCustomObject: .constant(nil))
            }
    }
}

// MARK: - Async Thumbnail Loader

private struct AsyncThumbnailButton: View {
    let object: CustomObject
    let onSelect: () -> Void
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Button(action: onSelect) {
            Group {
                if let loadedImage {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                } else if isLoading {
                    ProgressView()
                        .frame(width: 50, height: 50)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(SFSymbolButtonStyle(symbolSize: 40))
        .padding(.bottom, 10)
        .task(id: object.id) {
            await loadThumbnail()
        }
    }
    
    private func loadThumbnail() async {
        guard let imageData = object.imageData else {
            isLoading = false
            return
        }
        
        // Decode off the main thread
        let image = await Task.detached(priority: .userInitiated) {
            UIImage(data: imageData)
        }.value
        
        await MainActor.run {
            withAnimation {
                loadedImage = image
                isLoading = false
            }
        }
    }
}

