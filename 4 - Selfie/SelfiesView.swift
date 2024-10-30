//  Created by Louis Carbo Estaque on 28/11/2023.

import SwiftUI
import PhotosUI

struct SelfiesView: View {
    @Binding var screenNumber: Int
    @State private var selection: PhotosPickerItem? = nil
    
    var body: some View {
        VStack {
            CaptureView()
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
    SelfiesView(screenNumber: .constant(3))
}
