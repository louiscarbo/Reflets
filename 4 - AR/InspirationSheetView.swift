//
//  InspirationSheetView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 27/12/2024.
//

import SwiftUI

struct InspirationSheetView: View {
    @State var selectedIntention: Intention
    
    var body: some View {
        VStack {
            
        }
        .presentationBackground(.thinMaterial)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(40.0)
    }
}

#Preview {
    @Previewable @State var isPresented = false;
    
    ZStack {
        Image("previewImage")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        ARControlsView(
            artworkIsDone: .constant(false),
            arObjects: .constant([]),
            arObjectProperties: .constant(ARObjectProperties()),
            selectedIntention: Intentions.proud.details
        )
    }
}
