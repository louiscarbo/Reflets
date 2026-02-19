//
//  VisionBoard.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftData
import Foundation

@Model
class VisionBoard {
    var id: UUID
    var name: String
    var date: Date
    var lastOpened: Date
    @Relationship(deleteRule: .cascade) var objects: [ARObject]
    
    var completedChallengeIDs: [String] = []
    
    init() {
        self.id = UUID()
        self.name = "New Board"
        self.date = .now
        self.lastOpened = .now
        self.objects = []
        self.completedChallengeIDs = []
    }
}
