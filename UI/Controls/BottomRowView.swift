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
        @Bindable var bindableSession = session
        
        HStack(spacing: 20) {
            RepeatableButton(systemImage: "arrowshape.turn.up.backward") {
                session.removeLastObject()
            }
            .buttonStyle(SFSymbolButtonStyle(symbolSize: 60, rotateInTrigonometricDirection: true))
            .disabled(session.board.objects.isEmpty)
            
            RepeatableButton(systemImage: "plus") {
                session.addObject()
            }
            .buttonStyle(SFSymbolButtonStyle(symbolSize: 80))
            
            Button {
                session.showCustomizationSheet = true
            } label: {
                Image(systemName: "paintbrush")
            }
            .buttonStyle(SFSymbolButtonStyle(symbolSize: 60))
            .sheet(isPresented: $bindableSession.showCustomizationSheet) {
                ObjectSettingsView()
            }
        }
        .font(.title)
        .padding(.horizontal, 30)
        .padding(.vertical)
        .glassEffect(.clear)
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
