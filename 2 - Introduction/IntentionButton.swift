//  Created by Louis Carbo Estaque on 21/12/2024.

import SwiftUI

struct IntentionButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            let offset: CGFloat = 5

            Capsule()
                .frame(maxWidth: .infinity) // Constraint to the label's size
                .foregroundStyle(
                    LinearGradient(
                        colors:
                            configuration.isPressed ?
                        [
                            Color(red: 240/255, green: 200/255, blue: 234/255),
                            Color(red: 240/255, green: 180/255, blue: 115/255),
                        ] :
                        [
                            Color(red: 255/255, green: 216/255, blue: 244/255),
                            Color(red: 255/255, green: 189/255, blue: 125/255),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Capsule()
                .stroke(Color.black.opacity(0.1), lineWidth: 3)
            
            configuration.label
                .fontDesign(.serif)
                .italic()
                .fontWeight(.medium)
                .padding(.vertical, 15) // Add intrinsic height
                .padding(.horizontal, 50) // Add intrinsic width
        }
        .scaleEffect(configuration.isPressed ? 1.1 : 1)
        .rotationEffect(configuration.isPressed ? .degrees(-5) : .zero)
        .fixedSize()
    }
}

#Preview {
    ZStack {
        Rectangle()
            .foregroundStyle(.green)
        Button("What I'm proud of.") {
            
        }
        .buttonStyle(IntentionButton())
    }
}
