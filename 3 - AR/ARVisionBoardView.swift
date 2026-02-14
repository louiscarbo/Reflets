//
//  ARVisionBoardView.swift
//  TestRealityView
//
//  Created by Louis Carbo Estaque on 22/10/2024.
//

import SwiftUI
import RealityKit
import SwiftData

struct ARVisionBoardView: View {
    @Bindable var board: VisionBoard
    
    @State private var editingSession: AREditingSession
    @State private var sceneManager = ARSceneManager()
    
    let cameraAnchor = AnchorEntity(.camera)
    
    init(board: VisionBoard) {
        self.board = board
        self._editingSession = State(initialValue: AREditingSession(board: board))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: RealityView
            RealityView { content in
                content.camera = .spatialTracking
                content.add(cameraAnchor)
                
                sceneManager.updatePositioningHelper(
                    with: editingSession.currentObjectProperties,
                    in: cameraAnchor
                )
                
                sceneManager.initialize(
                    cameraAnchor: cameraAnchor,
                    existingObjects: board.objects,
                    content: content
                )
            } update: { content in
                sceneManager.handleUpdate(
                    content: content,
                    currentObjects: board.objects
                )
            }
            .ignoresSafeArea()
            .onChange(of: editingSession.artworkIsDone) {
                if editingSession.artworkIsDone {
                    cameraAnchor.children.removeAll()
                } else {
                    sceneManager.updatePositioningHelper(
                        with: editingSession.currentObjectProperties,
                        in: cameraAnchor
                    )
                }
            }
            
            // MARK: Controls Interface
            if !editingSession.artworkIsDone {
                ARControlsView(session: editingSession)
                    .onChange(of: editingSession.currentObjectProperties) {
                        sceneManager.updatePositioningHelper(
                            with: editingSession.currentObjectProperties,
                            in: cameraAnchor
                        )
                    }
            }
            
            // MARK: Validation Interface
            if editingSession.artworkIsDone {
                ARValidationView(board: board, artworkIsDone: $editingSession.artworkIsDone)
            }
        }
        .environment(\.editingSession, editingSession)
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VisionBoard.self, configurations: config)
    let board = VisionBoard()
    
    return ZStack {
        GeometryReader { geometry in
            Image("previewImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        ARVisionBoardView(board: board)
    }
    .modelContainer(container)
}
