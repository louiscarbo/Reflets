//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import Observation

@MainActor
@Observable
class ARVisionBoardViewModel {
    var board: VisionBoard
    var artworkIsDone: Bool
    var currentARObjectProperties: ARObjectProperties
    
    init(board: VisionBoard) {
        self.board = board
        self.artworkIsDone = false
        self.currentARObjectProperties = .init()
    }
}
