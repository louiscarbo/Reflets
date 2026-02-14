//
//  BottomRowView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

struct BottomRowView: View {
    @Environment(\.editingSession) private var session
    
    var body: some View {
        HStack(spacing: 20) {
            RepeatableButton(systemImage: "arrowshape.turn.up.backward") {
                session?.removeLastObject()
            }
            .buttonStyle(SFSymbolButtonStyle(rotateInTrigonometricDirection: true))
            .disabled(session?.board.objects.isEmpty ?? true)
            
            RepeatableButton(systemImage: "plus") {
                session?.addObject()
            }
            .buttonStyle(SFSymbolButtonStyle(symbolSize: 45))
            
            Button {
                session?.showCustomizationSheet = true
            } label: {
                Image(systemName: "paintbrush")
            }
            .buttonStyle(SFSymbolButtonStyle())
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

// MARK: - RepeatableButton
struct RepeatableButton: View {
    let systemImage: String
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled
    
    @State private var timer: Timer? = nil
    private let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        Button {
            action()
            invalidateTimer()
            hapticFeedback.notificationOccurred(.success)
        } label: {
            Image(systemName: systemImage)
        }
        .disabled(!isEnabled)
        .gesture(
            LongPressGesture(minimumDuration: 0.2)
                .onEnded { _ in
                    invalidateTimer()
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard isEnabled else { return }
                    if timer == nil {
                        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                            action()
                            hapticFeedback.notificationOccurred(.success)
                        }
                    }
                }
        )
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
