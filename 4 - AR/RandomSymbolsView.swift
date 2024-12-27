//
//  RandomSymbolsView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 27/12/2024.
//

import SwiftUI

struct RandomSymbolsView: View {
    var lightMode: Bool = true
    
    let allSymbols = [
        "paintbrush.pointed", "paintbrush", "photo", "camera", "trophy",
        "medal", "music.microphone", "theatermask.and.paintbrush",
        "lightbulb.max", "fireworks", "balloon.2", "party.popper",
        "crown", "movieclapper", "eyeglasses", "sunglasses",
        "gamecontroller", "paintpalette", "swatchpalette", "binoculars",
        "globe.europe.africa", "rainbow", "leaf", "camera.macro",
        "bubble.left.and.text.bubble.right", "star", "sparkles",
        "sun.max", "moon", "cloud.sun", "heart", "figure.2.left.holdinghands",
        "figure.badminton", "figure.wave", "figure.gymnastics", "figure.surfing",
        "eyes", "nose", "mouth", "mustache", "brain", "ear", "hourglass",
        "figure.2.and.child.holdinghands"
    ]
    
    let numberOfSelectedIcons: Int = 100
    let columns: Int = 5
    let symbolSize: CGFloat = 70
    
    @State private var selectedSymbols: [String] = []
        
    var body: some View {
        ZStack {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: columns),
                spacing: 5
            ) {
                ForEach(selectedSymbols.indices, id: \.self) { index in
                    Image(systemName: selectedSymbols[index])
                        .font(.system(size: symbolSize))
                        .frame(width: symbolSize, height: symbolSize)
                        .padding(20)
                        .rotationEffect(.degrees(Double.random(in: -50...50)))
                }
            }
            .fixedSize()
            .rotationEffect(.degrees(-10))
        }
        .offset(y: -50)
        .foregroundStyle(.black)
        .opacity(0.05)
        .onAppear {
            generateSelectedSymbols()
        }
    }
        
    private func generateSelectedSymbols() {
        selectedSymbols = []
        for _ in 0..<numberOfSelectedIcons {
            if let randomSymbol = allSymbols.randomElement() {
                selectedSymbols.append(randomSymbol)
            }
        }
        selectedSymbols.shuffle()
    }
}

#Preview {
    RandomSymbolsView()
}
