//
//  TopRowView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

struct TopRowView: View {
    @Environment(\.editingSession) private var session
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(spacing: 10) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
            }
            .buttonStyle(SFSymbolButtonStyle())
            
            Button {
                withAnimation {
                    session?.showInspirationSheet = true
                }
            } label: {
                Image("Reflets")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 31)
            }
            .buttonStyle(SFSymbolButtonStyle())
            
            Button {
                withAnimation {
                    session?.showObjectsCatalog = true
                }
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            .buttonStyle(SFSymbolButtonStyle())
            
            Button {
                withAnimation(.easeInOut(duration: 1.0)) {
                    session?.artworkIsDone = true
                }
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(SFSymbolButtonStyle())
        }
        .padding(.horizontal, 30)
        .padding(.vertical)
        .glassEffect(.clear)
    }
}

#Preview {
    ZStack {
        GeometryReader { geometry in
            Image("previewImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        ARVisionBoardView(board: VisionBoard())
    }
}
