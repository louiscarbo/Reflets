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
    
    @Binding var selectedType: SelectedType
    
    @State private var availableTypes: [SelectedType] = [.sphere, .cube, .cone, .cylinder, .text]
    
    var body: some View {
        let gridColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
        
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
                    
                    LazyVGrid(columns: gridColumns) {
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
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(SFSymbolButtonStyle())
                }
            }
        }
        .padding(25)
        .presentationBackground(.thinMaterial)
        .presentationDetents([.fraction(0.8), .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(40.0)
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
            shouldGoBack: .constant(false),
            shouldAddObject: .constant(false),
            showCustomizationSheet: .constant(false),
            sliderValue: .constant(0.8)
        )
        .sheet(isPresented: $isPresented) {
            ObjectsCatalogSheetView(selectedType: .constant(.cube))
        }
    }
}

