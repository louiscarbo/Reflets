//
//  ObjectsCatalogSheetView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI
import SwiftData

struct ObjectsCatalogSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedType: ARObjectType
    @Binding var selectedCustomObject: CustomObject?
    
    @State private var showObjectCaptureSheet = false
    @Query(sort: \CustomObject.createdAt, order: .reverse) private var customObjects: [CustomObject]
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    private let availableTypes: [ARObjectType] = [.sphere, .cube, .cone, .cylinder, .text]
    
    var body: some View {
        VStack {
            ScrollView {
                Text("Objects Catalog")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                
                VStack(alignment: .leading) {
                    SimpleShapesSection(
                        availableTypes: availableTypes,
                        onSelect: selectShape
                    )
                    
                    CustomObjectsSection(
                        customObjects: customObjects,
                        showObjectCaptureSheet: $showObjectCaptureSheet,
                        onSelect: selectCustomObject
                    )
                }
            }
            .padding(25)
        }
        .ignoresSafeArea()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showObjectCaptureSheet) {
            ObjectCaptureSheetView()
        }
    }
    
    private func selectShape(_ type: ARObjectType) {
        dismiss()
        hapticFeedback.notificationOccurred(.success)
        selectedType = type
    }
    
    private func selectCustomObject(_ object: CustomObject) {
        dismiss()
        hapticFeedback.notificationOccurred(.success)
        selectedType = .image
        selectedCustomObject = object
    }
}

#Preview {
    ARControlsView(session: .init(board: .init()))
        .sheet(isPresented: .constant(true)) {
            ObjectsCatalogSheetView(
                selectedType: .constant(.cube),
                selectedCustomObject: .constant(nil)
            )
        }
}

// MARK: - Simple Shapes Section

private struct SimpleShapesSection: View {
    let availableTypes: [ARObjectType]
    let onSelect: (ARObjectType) -> Void
    
    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
    
    var body: some View {
        Divider()
        
        Text("Simple Shapes")
            .fontWidth(.expanded)
            .font(.title2)
        
        LazyVGrid(columns: Self.columns) {
            ForEach(availableTypes, id: \.self) { type in
                Button {
                    onSelect(type)
                } label: {
                    Image(systemName: type.SFSymbolName)
                }
                .buttonStyle(SFSymbolButtonStyle())
                .padding(.bottom, 10)
            }
        }
    }
}

// MARK: - Custom Objects Section

private struct CustomObjectsSection: View {
    let customObjects: [CustomObject]
    @Binding var showObjectCaptureSheet: Bool
    let onSelect: (CustomObject) -> Void
    
    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        Divider()
        
        Text("Custom Objects")
            .fontWidth(.expanded)
            .font(.title2)
        
        LazyVGrid(columns: Self.columns) {
            ForEach(customObjects) { object in
                AsyncThumbnailButton(
                    object: object,
                    onSelect: { onSelect(object) }
                )
            }
            
            Button {
                showObjectCaptureSheet = true
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(SFSymbolButtonStyle(symbolSize: 43))
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

