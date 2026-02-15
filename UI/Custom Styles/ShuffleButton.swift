//  Created by Louis Carbo Estaque on 28/12/2024.

import SwiftUI

struct ShuffleButton: ButtonStyle {
    var horizontalPadding: CGFloat = 50
    
    @State private var offset: Float = 0.0
    @State private var colorShift: [Color] = [
        .orange, .pink, .purple, .orange,
        .orange, .pink, .purple, .orange,
        .yellow, .pink, .purple, .red
    ]

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Capsule()
                .frame(maxWidth: .infinity) // Constraint to the label's size
                .foregroundStyle(
                    MeshGradient(
                        width: 4,
                        height: 3,
                        points: [
                            [0.0, 0.0], [0.33, 0.0], [0.66, 0.0], [1.0, 0.0],
                            [0.0, 0.5 - offset], [0.33, 0.5 - offset], [0.66, 0.5 - offset], [1.0, 0.5 - offset],
                            [0.0, 1.0], [0.33, 1.0], [0.66, 1.0], [1.0, 1.0]
                        ],
                        colors: colorShift
                    )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                .onAppear {
                    // Animate the color shifts in the gradient
                    withAnimation(.easeInOut(duration: 4.0).repeatForever()) {
                        colorShift = [
                            .yellow, .orange, .pink, .purple,
                            .orange, .pink, .pink, .orange,
                            .pink, .orange, .orange, .yellow
                        ]
                    }
                }
                .onChange(of: configuration.isPressed) {
                    withAnimation(.easeOut) {
                        colorShift = configuration.isPressed ? [
                            .yellow, .orange, .pink, .yellow,
                            .orange, .pink, .pink, .yellow,
                            .pink, .orange, .orange, .yellow
                        ] : [
                            .orange, .pink, .purple, .orange,
                            .orange, .pink, .purple, .orange,
                            .yellow, .pink, .purple, .red
                        ]
                    }
                }
            
            Capsule()
                .stroke(Color.black.opacity(0.1), lineWidth: 5)
                .blur(radius: 2)
                .clipShape(Capsule())
            
            configuration.label
                .foregroundColor(.black.opacity(0.8))
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
        Button {
            
        } label: {
            Label("New Challenge", systemImage: "shuffle")
        }
        .buttonStyle(ShuffleButton())
    }
}
