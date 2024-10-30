//  Created by Louis Carbo Estaque on 28/11/2023.

import SwiftUI

struct HomeView: View {
    @Binding var screenNumber: Int
    
    var body: some View {
        VStack {
            Text("Reflets")
                .bold()
                .font(.system(.largeTitle, design: .rounded))
            Button("Start the experience") {
                withAnimation {
                    screenNumber += 1
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .font(.title3)
            .bold()
        }
    }
}

#Preview {
    HomeView(screenNumber: .constant(0))
}
