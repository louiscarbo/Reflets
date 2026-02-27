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
    @Namespace private var namespace
    @State private var showObjectCaptureSheet = false
    let onSelect: (Sticker) -> Void
    
    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    
    var body: some View {
        Divider()
        
        Text("My Stickers")
            .fontWidth(.expanded)
            .font(.title2)
        
        LazyVGrid(columns: Self.columns) {
            Button {
                showObjectCaptureSheet = true
            } label: {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundStyle(.secondary)
                    .frame(width: 90, height: 90)
                    .overlay {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
            }
            .buttonStyle(.plain)
            .contentShape(.rect)
            .matchedTransitionSource(id: "objectCapture", in: namespace)
            .sheet(isPresented: $showObjectCaptureSheet) {
                StickerCaptureSheetView()
                    .navigationTransition(
                            .zoom(sourceID: "objectCapture", in: namespace)
                        )
            }
            
            ForEach(stickers) { object in
                AsyncThumbnailButton(
                    object: object,
                    onSelect: { onSelect(object) }
                )
            }
        }
    }
}

// MARK: - Async Thumbnail Loader

private struct AsyncThumbnailButton: View {
    let object: Sticker
    let onSelect: () -> Void
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = true

    private let outlineWidth: Float = 5
    
    var body: some View {
        Button(action: onSelect) {
            Group {
                if let loadedImage {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .layerEffect(
                            ShaderLibrary.outline(.float(outlineWidth)),
                            maxSampleOffset: CGSize(
                                width: CGFloat(outlineWidth),
                                height: CGFloat(outlineWidth)
                            )
                        )
                        .shadow(radius: 4, y: 4)
                } else if isLoading {
                    ProgressView()
                        .frame(width: 90, height: 90)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(StickerButtonStyle())
        .padding(.bottom, 10)
        .task(id: object.id) {
            await loadThumbnail()
        }
    }
    
    private func loadThumbnail() async {
        // Prefer the pre-generated small thumbnail; fall back to the full image.
        let data = object.thumbnailData ?? object.imageData
        let hasThumbnail = object.thumbnailData != nil
        guard let data else {
            isLoading = false
            return
        }
        
        // If we fell back to the full image, use ImageIO to subsample at decode time.
        let image = await Task.detached(priority: .userInitiated) { () -> UIImage? in
            if hasThumbnail {
                return UIImage(data: data)
            } else {
                return ImageProcessingService.makeThumbnailData(from: data)
                    .flatMap { UIImage(data: $0) }
            }
        }.value
        
        await MainActor.run {
            withAnimation {
                loadedImage = image
                isLoading = false
            }
        }
    }
}

// MARK: - Sticker Button Style

private struct StickerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

