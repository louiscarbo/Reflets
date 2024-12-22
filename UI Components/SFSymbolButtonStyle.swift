//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI

struct SFSymbolButtonStyle: ButtonStyle {
    var symbolSize: CGFloat = 30
    var foregroundColor: Color = .black
    var backgroundColor: Color = Color(red: 240/255, green: 240/255, blue: 230/255)
    var pressedEffectScale: CGFloat = 0.9
    var rotateInTrigonometricDirection: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .foregroundStyle(backgroundColor)
                .frame(maxWidth: .infinity)
                .shadow(radius: 5.0)
                        
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 0.5),
                            Color(red: 0/255, green: 0/255, blue: 0/255, opacity: 0.3)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 7)
                .opacity(configuration.isPressed ? 0.4 : 1.0)
                .blur(radius: 2)
                .clipShape(Circle())
            
            Circle()
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 255/255, green: 255/255, blue: 255/255, opacity: 1.0),
                            Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom)
                    .opacity(configuration.isPressed ? 0.1 : 0.2)
                )
                .padding(9)
                .offset(y: -2)
                .blur(radius: 4)
            
            configuration.label
                .offset(y: -2)
                .font(.system(size: symbolSize)) // SF Symbol size
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor) // Icon color
                .padding()
                .rotationEffect(configuration.isPressed ? .degrees(rotateInTrigonometricDirection ? -15 : 15) : .zero)
            
            Circle()
                .foregroundStyle(Color.black.opacity(configuration.isPressed ? 0.1 : 0.0))
        }
        .fixedSize()
        .scaleEffect(configuration.isPressed ? pressedEffectScale : 1.0) // Pressed effect
    }
}

#Preview {
    ZStack(alignment: .top) {
        Rectangle()
            .foregroundStyle(.green)
        HStack {
            Button {
                
            } label: {
                Image(systemName: "arrowshape.turn.up.backward")
            }
            .padding()
            .buttonStyle(SFSymbolButtonStyle(rotateInTrigonometricDirection: true))
            Button {
                
            } label: {
                Image(systemName: "checkmark")
            }
            .padding()
            .buttonStyle(SFSymbolButtonStyle())
        }
    }
}
