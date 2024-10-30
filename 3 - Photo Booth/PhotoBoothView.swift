//  Created by Louis Carbo Estaque on 28/11/2023.

import SwiftUI

struct PhotoBoothView: View {
    @Binding var screenNumber: Int

    var body: some View {
        VStack {
            Text("Photo Booth")
                .font(.system(.title2, design: .rounded))
            Button("Next view") {
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
    PhotoBoothView(screenNumber: .constant(2))
}
