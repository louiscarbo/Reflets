//  Created by Louis Carbo Estaque on 28/11/2023.

import SwiftUI

struct HomeView: View {
    @Binding var screenNumber: Int
    @Binding var rotationAngle: Double
    
    var body: some View {
        VStack(spacing: 0) {
            Image("Reflets")
                .resizable()
                .scaledToFit()
                .frame(height: 170)
                .rotationEffect(.degrees(rotationAngle))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 10.0)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotationAngle = 360.0
                    }
                }
            Text("Reflets")
                .bold()
                .font(.system(size: 70))
                .fontWeight(.light)
                .fontWidth(.expanded)
                .padding(.bottom, 20)
            Button("Start the experience") {
                withAnimation(.easeInOut(duration: 1.0)) {
                    screenNumber+=1
                }
            }
            .buttonStyle(TitleButton())
            .buttonBorderShape(.capsule)
            .fontWeight(.medium)
            .fontWidth(.expanded)
        }
    }
}

#Preview {
    HomeView(screenNumber: .constant(0), rotationAngle: .constant(0))
}
