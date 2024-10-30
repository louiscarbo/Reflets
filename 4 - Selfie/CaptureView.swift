//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 15/10/2024.
//

import SwiftUI

struct CaptureView: View {
    @ObservedObject var cameraViewModel = SelfieViewModel()

    var body: some View {
        ZStack {
            // Camera feed from AVCaptureSession
            SelfieFeedView(session: cameraViewModel.session)
                .onAppear {
                    cameraViewModel.setupCamera()
                }

            VStack {
                Spacer()

                Button(action: {
                    cameraViewModel.capturePhoto()
                }) {
                    Text("Capture Selfie")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }

                if let image = cameraViewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                        .padding()
                }
            }
        }
    }
}
