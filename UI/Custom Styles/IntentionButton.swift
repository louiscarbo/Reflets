//  Created by Louis Carbo Estaque on 21/12/2024.

import SwiftUI

struct IntentionButton: ButtonStyle {
    var horizontalPadding: CGFloat = 50
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
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
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            
            Capsule()
                .stroke(Color.black.opacity(0.1), lineWidth: 5)
                .blur(radius: 2)
                .clipShape(Capsule())
            
            configuration.label
                .foregroundColor(.black)
                .fontWidth(.expanded)
                .fontWeight(.medium)
                .padding(.vertical, 15)
                .padding(.horizontal, horizontalPadding)
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
        VStack {
            Button("Where I feel at home") {
                
            }
            .buttonStyle(IntentionButton())
            Button {
                
            } label: {
                Label("Where I feel at home", systemImage: "house")
            }
            .buttonStyle(IntentionButton())
        }
    }
}
