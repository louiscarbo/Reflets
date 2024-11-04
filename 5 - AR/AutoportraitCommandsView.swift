//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 29/10/2024.
//

import SwiftUI

struct AutoportraitCommandsView: View {
    @Binding var screenNumber: Int
    
    @State private var alertIsPresented: Bool = false
    
    var body: some View {
        VStack {
            // Top row
            HStack {
                Button("New Selfie", systemImage: "camera.fill") {
                    alertIsPresented = true
                }
                .alert("This selfie will be lost", isPresented: $alertIsPresented) {
                    Button("Cancel", role: .cancel) { }
                    Button("Take a new selfie") {
                        screenNumber = screenNumber - 1
                    }
                } message: {
                    Text("By taking a new selfie, you will lose the current one. Are you sure?")
                }
                .buttonBorderShape(.capsule)
                .tint(.black.opacity(0.7))
                .buttonStyle(.borderedProminent)
                .padding()
                                
                Button("Custom Objects", systemImage: "folder.fill") {
                    
                }
                .buttonBorderShape(.capsule)
                .tint(.black.opacity(0.7))
                .buttonStyle(.borderedProminent)
                .padding()
            }
            
            Spacer()
            
            // Slider
            HStack {
                Spacer()
            }
            
            Spacer()
            
            // Bottom row
            HStack {
                
            }
        }
    }
}

#Preview {
    AutoportraitCommandsView(screenNumber: .constant(1))
}
