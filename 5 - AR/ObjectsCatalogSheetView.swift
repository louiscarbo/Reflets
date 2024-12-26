//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI

struct ObjectsCatalogSheetView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    @Binding var selectedType: ARObjectType
    @Binding var imageURL: URL?
    
    @State private var availableTypes: [ARObjectType] = [.sphere, .cube, .cone, .cylinder, .text]
    
    @State private var showObjectCaptureSheet: Bool = false
    
    @State private var shouldUpdateCustomObjects = false
    @State private var customObjects: [CustomObjectPreview] = []
    
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
                        ForEach(customObjects, id: \.self) { object in
                            Button {
                                dismiss()
                                hapticFeedback.notificationOccurred(.success)
                                selectedType = .image
                                imageURL = object.url
                            } label: {
                                Image(uiImage: object.preview)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                            .buttonStyle(SFSymbolButtonStyle(symbolSize: 40))
                            .padding(.bottom, 10)
                        }
                        Button {
                            showObjectCaptureSheet = true
                            
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(SFSymbolButtonStyle(symbolSize: 43))
                        .sheet(isPresented: $showObjectCaptureSheet) {
                            ObjectCaptureSheetView(shouldUpdateCustomObjects: $shouldUpdateCustomObjects)
                        }
                    } // LazyVGrid
                    .onChange(of: shouldUpdateCustomObjects) {
                        Task {
                            await updateCustomObject()
                        }
                    }
                    .onAppear {
                        Task {
                            await updateCustomObject()
                        }
                    }
                }
            }
            .padding(25)
        }
        .ignoresSafeArea()
        .presentationBackground(.thinMaterial)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(40.0)
    }
    
    func updateCustomObject() async {
        customObjects = await fetchSegmentedImagesFromTemporaryDirectory()
        DispatchQueue.main.async {
            shouldUpdateCustomObjects = false
        }
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
        ARControlsView(
            showReflectoHelp: .constant(false),
            showObjectsCatalog: $isPresented,
            artworkIsDone: .constant(false),
            showCustomizationSheet: .constant(false),
            arObjects: .constant([]),
            arObjectProperties: .constant(ARObjectProperties())
        )
        .sheet(isPresented: $isPresented) {
            ObjectsCatalogSheetView(selectedType: .constant(.cube), imageURL: .constant(nil))
        }
    }
}

