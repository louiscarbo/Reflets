//
//  ChallengeCompletionView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

struct ChallengeCompletionView: View {
    @Environment(\.editingSession) private var session
    
    var body: some View {
        if let session = session, session.congratulationEffect {
            VStack {
                Text("\(session.completedChallenges.count)/\(challenges.count) completed!")
                    .fontWidth(.expanded)
                Gauge(value: session.gaugeValue, in: 0...Double(challenges.count)) { }
                    .tint(Gradient(colors: [.purple, .pink, .yellow]))
                    .gaugeStyle(.accessoryCircularCapacity)
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(.ultraThinMaterial.opacity(1.0))
                    .blur(radius: 5)
                    .allowsHitTesting(false)
            }
            .transition(.scale)
        }
    }
}
