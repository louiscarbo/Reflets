//
//  EnvironmentValues+AREditingSession.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI

private struct EditingSessionKey: EnvironmentKey {
    @MainActor static var defaultValue: AREditingSession {
        AREditingSession(board: VisionBoard())
    }
}

extension EnvironmentValues {
    var editingSession: AREditingSession {
        get { self[EditingSessionKey.self] }
        set { self[EditingSessionKey.self] = newValue }
    }
}
