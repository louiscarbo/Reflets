//
//  VolumeButtonListener.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 22/12/2024.
//

import SwiftUI
import AVFoundation
import MediaPlayer

class VolumeButtonListener: ObservableObject {
    var onVolumeDown: (() -> Void)?
    private var initialVolume: Float = AVAudioSession.sharedInstance().outputVolume
    private var volumeView: MPVolumeView?

    init() {
        setupVolumeObserver()
        setupHiddenVolumeView()
    }

    private func setupVolumeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(volumeDidChange(notification:)),
            name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil
        )
    }

    private func setupHiddenVolumeView() {
        // Hide the system volume control indicator
        let volumeView = MPVolumeView(frame: .zero)
        self.volumeView = volumeView
        volumeView.isHidden = true
        UIApplication.shared.windows.first?.addSubview(volumeView)
    }

    @objc private func volumeDidChange(notification: Notification) {
        let currentVolume = AVAudioSession.sharedInstance().outputVolume

        // Check if Volume - was pressed
        if currentVolume < initialVolume {
            onVolumeDown?() // Trigger the custom action
        }

        // Update the initial volume
        initialVolume = currentVolume
    }
}
