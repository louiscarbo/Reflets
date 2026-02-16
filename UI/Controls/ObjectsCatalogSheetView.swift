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
    @Binding var selectedsticker: Sticker?
    
    @State private var showObjectCaptureSheet = false
    @Query(sort: \Sticker.createdAt, order: .reverse) private var stickers: [Sticker]
    
    private let hapticFeedback = UINotificationFeedbackGenerator()
    private let availableTypes: [ARObjectType] = [.sphere, .cube, .cone, .cylinder, .text]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Objects Catalog")
                    .font(.title)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                
                VStack(alignment: .leading) {
                    SimpleShapesSection(
                        availableTypes: availableTypes,
                        onSelect: selectShape
                    )
                    
                    MyStickersSection(
                        stickers: stickers,
                        showObjectCaptureSheet: $showObjectCaptureSheet,
                        onSelect: selectsticker
                    )
                }
            }
            .background {
                RandomSymbolsView()
            }
            .padding(25)
        }
        .ignoresSafeArea()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showObjectCaptureSheet) {
            StickerCaptureSheetView()
        }
    }
    
    private func selectShape(_ type: ARObjectType) {
        dismiss()
        hapticFeedback.notificationOccurred(.success)
        selectedType = type
    }
    
    private func selectsticker(_ object: Sticker) {
        dismiss()
        hapticFeedback.notificationOccurred(.success)
        selectedType = .image
        selectedsticker = object
    }
}

#Preview {
    ARControlsView(session: .init(board: .init()))
        .sheet(isPresented: .constant(true)) {
            ObjectsCatalogSheetView(
                selectedType: .constant(.cube),
                selectedsticker: .constant(nil)
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
                .buttonStyle(SFSymbolButtonStyle(symbolSize: 70))
                .font(.title)
                .padding(.bottom, 10)
            }
        }
    }
}

// MARK: - My Stickers Section

private struct MyStickersSection: View {
    let stickers: [Sticker]
    @Binding var showObjectCaptureSheet: Bool
    let onSelect: (Sticker) -> Void
    
    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        Divider()
        
        Text("My Stickers")
            .fontWidth(.expanded)
            .font(.title2)
        
        LazyVGrid(columns: Self.columns) {
            ForEach(stickers) { object in
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
        }
        .buttonStyle(SFSymbolButtonStyle(symbolSize: 90))
        .font(.title)
    }
}

// MARK: - Async Thumbnail Loader

private struct AsyncThumbnailButton: View {
    let object: Sticker
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

