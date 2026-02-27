//
//  ChallengeDetailView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

struct ChallengeDetailView: View {
    @Environment(\.editingSession) private var session
    let nameSpace: Namespace.ID
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        if session.focusChallengeMode, let challenge = session.selectedChallenge {
            VStack {
                TooltipView(
                    title: challenge.title,
                    text: challenge.prompt
                )
                .matchedGeometryEffect(id: "challengeView", in: nameSpace, properties: .position)
                
                HStack {
                    Button {
                        withAnimation {
                            session.selectedChallenge = nil
                            session.focusChallengeMode.toggle()
                        }
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .buttonStyle(TitleButton())
                    .animation(.bouncy(extraBounce: 0.5), value: session.focusChallengeMode)
                    
                    Button {
                        withAnimation {
                            hapticFeedback.notificationOccurred(.success)
                            session.completeChallenge(challenge)
                        }
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                    .buttonStyle(TitleButton())
                    .animation(.bouncy(extraBounce: 0.5), value: session.focusChallengeMode)
                }
                .offset(y: -40)
            }
        }
    }
}
