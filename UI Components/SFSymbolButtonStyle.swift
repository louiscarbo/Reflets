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
    var rotateInTrigonometricDirection: Bool = false
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let disabled = isEnabled == false
        let pressedEffectScale: CGFloat = disabled ? 1.0 : 0.9
        
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
                .opacity(
                    disabled ? 1.0 :
                        configuration.isPressed ? 0.4 : 1.0
                )
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
                    .opacity(
                        disabled ? 0.2 :
                            configuration.isPressed ? 0.1 : 0.2
                    )
                )
                .padding(0.3 * symbolSize)
                .offset(y: -2)
                .blur(radius: 4)
            
            configuration.label
                .offset(y: -2)
                .font(.system(size: symbolSize)) // SF Symbol size
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor) // Icon color
                .padding(16/30 * symbolSize)
                .rotationEffect(
                    disabled ? .zero :
                        configuration.isPressed ? .degrees(rotateInTrigonometricDirection ? -15 : 15) : .zero
                )
                .opacity(disabled ? 0.3 : 1.0)
            
            Circle()
                .foregroundStyle(
                    Color.black.opacity(
                        disabled ? 0.0 :
                            configuration.isPressed ? 0.1 : 0.0
                    )
                )
        }
        .fixedSize()
        .scaleEffect(configuration.isPressed ? pressedEffectScale : 1.0) // Pressed effect
    }
}

#Preview {
    @Previewable @State var bool = false
    
    ZStack(alignment: .top) {
        Rectangle()
            .foregroundStyle(.green)
        HStack {
            Button {
                
            } label: {
                Image(systemName: "gearshape")
            }
            .padding()
            .buttonStyle(SFSymbolButtonStyle(rotateInTrigonometricDirection: true))
            .disabled(bool)
            
            Button {
                bool.toggle()
            } label: {
                Image(systemName: "folder")
            }
            .padding()
            .buttonStyle(SFSymbolButtonStyle())
            
            Button("Hi bitches") {
                
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .disabled(true)
        }
    }
}
