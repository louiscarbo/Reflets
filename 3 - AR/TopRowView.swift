//
//  TopRowView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

struct TopRowView: View {
    @Environment(\.editingSession) private var session
    
    var body: some View {
        HStack(spacing: 10) {
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
            .buttonStyle(SFSymbolButtonStyle(symbolSize: 16))
            
            Button {
                withAnimation {
                    session?.showObjectsCatalog = true
                }
            } label: {
                Image(systemName: "folder.badge.plus")
            }
            .buttonStyle(SFSymbolButtonStyle(symbolSize: 20))
            
            Button {
                withAnimation(.easeInOut(duration: 1.0)) {
                    session?.artworkIsDone = true
                }
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(SFSymbolButtonStyle(symbolSize: 20))
        }
        .padding(.horizontal, 30)
        .padding(.vertical)
        .background {
            ZStack {
                Capsule()
                    .foregroundStyle(.thinMaterial.opacity(0.7))
                    .shadow(radius: 10)
                
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.black.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing),
                        lineWidth: 15)
                    .blur(radius: 4)
                    .clipShape(Capsule())
            }
        }
    }
}
