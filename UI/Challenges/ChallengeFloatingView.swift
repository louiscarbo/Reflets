//
//  ChallengeFloatingView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

struct ChallengeFloatingView: View {
    @Environment(\.editingSession) private var session
    
    var body: some View {
        if !session.focusChallengeMode, let challenge = session.selectedChallenge {
            Button {
                withAnimation {
                    session.toggleChallengeFocus()
                }
            } label: {
                PromptView(
                    title: challenge.title,
                    prompt: challenge.prompt,
                    sfSymbol: challenge.sfSymbol,
                    scrollEffect: false,
                    slimVersion: true
                )
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .padding(.leading, 50)
        }
    }
}
