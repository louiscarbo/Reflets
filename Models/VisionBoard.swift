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
    @Relationship(deleteRule: .cascade) var objects: [ARObject]
    
    var completedChallengeIDs: [String] = []
    
    init() {
        self.id = UUID()
        self.name = ""
        self.date = .now
        self.objects = []
        self.completedChallengeIDs = []
    }
}
