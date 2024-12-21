//  Created by Louis Carbo Estaque on 21/12/2024.

import SwiftUI

struct TitleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Capsule()
                .frame(maxWidth: .infinity) // Constraint to the label's size
                .foregroundStyle(
                    LinearGradient(
                        colors:
                            configuration.isPressed ?
                        [
                            Color(red: 245/255, green: 110/255, blue: 50/255),
                            Color(red: 240/255, green: 60/255, blue: 0/255),
                        ] :
                        [
                            Color(red: 255/255, green: 120/255, blue: 60/255),
                            Color(red: 250/255, green: 70/255, blue: 0/255),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Capsule()
                .stroke(Color.black.opacity(0.1), lineWidth: 4)
                .blur(radius: 2)
                .clipShape(Capsule())
            
            configuration.label
                .foregroundStyle(.white)
                .fontWidth(.expanded)
                .fontWeight(.medium)
                .padding(.vertical, 15)
                .padding(.horizontal, 30)
        }
        .scaleEffect(configuration.isPressed ? 1.05 : 1)
        .rotationEffect(configuration.isPressed ? .degrees(-1) : .zero)
        .fixedSize()
    }
}

#Preview {
    ZStack {
        Rectangle()
            .foregroundStyle(.green)
        Button("Start the experience") {
            
        }
        .buttonStyle(TitleButton())
    }
}
