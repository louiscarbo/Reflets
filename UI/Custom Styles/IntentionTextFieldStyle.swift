//
//  IntentionTextFieldStyle.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 06/01/2025.
//

import SwiftUI

struct IntentionTextFieldStyle: TextFieldStyle {
    var horizontalPadding: CGFloat = 30
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            Capsule()
                .frame(maxWidth: .infinity) // Constraint to the field's size
                .foregroundStyle(
                    LinearGradient(
                        colors: [
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
            
            configuration
                .padding(.vertical, 15)
                .padding(.horizontal, horizontalPadding)
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.black)
                .fontWidth(.expanded)
                .background(Color.clear)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    ZStack {
        Rectangle()
            .foregroundStyle(.green)
        VStack(spacing: 20) {
            TextField("Placeholder", text: .constant(""))
                .textFieldStyle(IntentionTextFieldStyle())
            TextField("Another Example", text: .constant(""))
                .textFieldStyle(IntentionTextFieldStyle())
        }
        .padding()
    }
}
