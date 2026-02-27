//
//  AREditingSession.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftUI
import Observation

@MainActor
@Observable
class AREditingSession {
    // MARK: - Persisted Data Reference
    var board: VisionBoard
    
    // MARK: - Transient UI State
    var artworkIsDone: Bool = false
    var currentObjectProperties = ARObjectProperties()
    
    // Challenge UI State  
    var selectedChallenge: Challenge?
    var focusChallengeMode: Bool = false
    var congratulationEffect: Bool = false
    var gaugeValue: Double = 0
    
    // Sheet presentation
    var showInspirationSheet: Bool = false
    var showObjectsCatalog: Bool = false
    var showCustomizationSheet: Bool = false
    
    // MARK: - Computed Properties
    
    var availableChallenges: [Challenge] {
        let completedSet = Set(board.completedChallengeIDs)
        return challenges.filter { !completedSet.contains($0.id) }
    }
    
    var completedChallenges: [Challenge] {
        let completedSet = Set(board.completedChallengeIDs)
        return challenges.filter { completedSet.contains($0.id) }
    }
    
    var challengeProgress: Double {
        guard !challenges.isEmpty else { return 0 }
        return Double(completedChallenges.count) / Double(challenges.count)
    }
    
    // MARK: - Initialization
    
    init(board: VisionBoard) {
        self.board = board
    }
    
    // MARK: - Actions
    
    func addObject() {
        let newObject = ARObject(properties: currentObjectProperties)
        board.objects.append(newObject)
    }
    
    func removeLastObject() {
        guard !board.objects.isEmpty else { return }
        board.objects.removeLast()
    }
    
    func completeChallenge(_ challenge: Challenge) {
        guard !board.completedChallengeIDs.contains(challenge.id) else { return }
        board.completedChallengeIDs.append(challenge.id)
        selectedChallenge = nil
        focusChallengeMode = false
        
        congratulationEffect = true
        gaugeValue = Double(completedChallenges.count) - 1
        
        // Animate gauge
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            gaugeValue = Double(completedChallenges.count)
            
            try? await Task.sleep(for: .milliseconds(2000))
            congratulationEffect = false
        }
    }
    
    func selectChallenge(_ challenge: Challenge) {
        selectedChallenge = challenge
    }
}
