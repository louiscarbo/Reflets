//
//  ChallengeDetailView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

struct ChallengeDetailView: View {
    @Environment(\.editingSession) private var session
    
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        if let session = session, session.focusChallengeMode, let challenge = session.selectedChallenge {
            VStack {
                TooltipView(
                    title: challenge.title,
                    text: challenge.prompt
                )
                
                HStack {
                    Button {
                        withAnimation {
                            session.toggleChallengeFocus()
                        }
                    } label: {
                        Label("Back", systemImage: "arrowshape.turn.up.backward")
                    }
                    .buttonStyle(TitleButton())
                    
                    Button {
                        withAnimation {
                            hapticFeedback.notificationOccurred(.success)
                            session.completeChallenge(challenge)
                        }
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                    .buttonStyle(TitleButton())
                }
                .offset(y: -40)
            }
        }
    }
}
