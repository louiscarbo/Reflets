//
//  MotionManager.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 27/02/2026.
//

import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    @Published var roll: Double = 0
    @Published var pitch: Double = 0

    private let manager = CMMotionManager()

    func start() {
        guard manager.isDeviceMotionAvailable else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let data else { return }
            withAnimation(.interpolatingSpring(stiffness: 50, damping: 25)) {
                self?.roll = data.attitude.roll
                self?.pitch = data.attitude.pitch
            }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
