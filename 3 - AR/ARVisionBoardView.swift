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
    @State private var artworkIsDone = false
    @State private var currentARObjectProperties = ARObjectProperties()
    
    @State private var sceneManager = ARSceneManager()
    
    let cameraAnchor = AnchorEntity(.camera)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: RealityView
            RealityView { content in
                content.camera = .spatialTracking
                content.add(cameraAnchor)
                
                sceneManager.updatePositioningHelper(
                    with: currentARObjectProperties,
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
            .onChange(of: artworkIsDone) {
                if artworkIsDone {
                    cameraAnchor.children.removeAll()
                } else {
                    sceneManager.updatePositioningHelper(
                        with: currentARObjectProperties,
                        in: cameraAnchor
                    )
                }
            }
            
            // MARK: Controls Interface
            if !artworkIsDone {
                ARControlsView(
                    artworkIsDone: $artworkIsDone,
                    arObjects: $board.objects,
                    arObjectProperties: $currentARObjectProperties
                )
                .onChange(of: currentARObjectProperties) {
                    sceneManager.updatePositioningHelper(
                        with: currentARObjectProperties,
                        in: cameraAnchor
                    )
                }
            }
            
            // MARK: Validation Interface
            if artworkIsDone {
                ARValidationView(board: board, artworkIsDone: $artworkIsDone)
            }
        }
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