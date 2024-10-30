//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 15/10/2024.
//
// This view is the UIKit view representing the camera feed
//

import SwiftUI
import AVFoundation

struct SelfieFeedView: UIViewRepresentable {
    var session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Store the preview layer in the coordinator to access later
        context.coordinator.previewLayer = previewLayer

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Ensure the preview layer resizes correctly when the view's bounds change
        DispatchQueue.main.async {
            if let previewLayer = context.coordinator.previewLayer {
                previewLayer.frame = uiView.bounds
                print("Preview Layer updated with bounds: \(uiView.bounds)")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var previewLayer: AVCaptureVideoPreviewLayer?
    }
}

#Preview {
    SelfieFeedView(session: .init())
}
