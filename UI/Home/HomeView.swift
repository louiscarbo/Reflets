//
//  SwiftUIView.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 28/11/2023.

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Query(sort: \VisionBoard.lastOpened, order: .reverse) private var boards: [VisionBoard]
    @Namespace private var namespace

    @State private var boardToRename: VisionBoard? = nil
    @State private var renameText: String = ""
    @State private var boardToDelete: VisionBoard? = nil
    
    // Gradient definitions
    var lightGradient: [Color] {
        [Color(red: 255/255, green: 250/255, blue: 250/255),
         Color(red: 255/255, green: 220/255, blue: 180/255)]
    }
    
    var darkGradient: [Color] {
        [Color(red: 0/255, green: 5/255, blue: 5/255),
         Color(red: 60/255, green: 30/255, blue: 40/255)]
    }

    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(
                    RadialGradient(
                        colors: colorScheme == .light ? lightGradient : darkGradient,
                        center: .center,
                        startRadius: 0, endRadius: 500
                    )
                )
            
            VStack {
                // Header
                HStack {
                    Image("Reflets")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                    Text("Reflets")
                        .font(.title)
                        .fontWidth(.expanded)
                    Spacer()
                    Button("New Board", systemImage: "plus", action: createNewBoard)
                        .fontWidth(.expanded)
                        .buttonStyle(.glassProminent)
                        .tint(.orange)
                }
                .padding()
                
                if boards.isEmpty {
                    ContentUnavailableView(
                        "No Vision Boards",
                        systemImage: "wand.and.stars",
                        description: Text("Create your first AR Vision Board by tapping \"New Board\".")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 0),
                            GridItem(.flexible(), spacing: 0)
                        ], spacing: 0) {
                            ForEach(boards) { board in
                                NavigationLink {
                                    ARVisionBoardView(board: board)
                                        .navigationTransition(.zoom(sourceID: board.id, in: namespace))
                                        .onAppear {
                                            board.lastOpened = .now
                                        }
                                } label: {
                                    VisionBoardGridCell(board: board)
                                        .matchedTransitionSource(id: board.id, in: namespace)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        renameText = board.name
                                        boardToRename = board
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        boardToDelete = board
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete \"\(boardToDelete?.name ?? "")\"?",
            isPresented: Binding(get: { boardToDelete != nil }, set: { if !$0 { boardToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let board = boardToDelete { deleteBoard(board) }
                boardToDelete = nil
            }
        } message: {
            Text("This vision board and all its objects will be permanently deleted.")
        }
        .sheet(item: $boardToRename) { board in
            RenameBoardSheet(board: board, renameText: $renameText) {
                boardToRename = nil
            }
            .presentationDetents([.height(260)])
        }
    }
    
    private func createNewBoard() {
        let newBoard = VisionBoard()
        modelContext.insert(newBoard)
    }
    
    private func deleteBoard(_ board: VisionBoard) {
        modelContext.delete(board)
    }
}

struct RenameBoardSheet: View {
    @FocusState private var isFocused: Bool
    @Bindable var board: VisionBoard
    @Binding var renameText: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("What would you like to call this vision board?")
                .padding(40)
                .multilineTextAlignment(.center)
                .font(.title2)
                .fontWidth(Font.Width(0.05))
                .foregroundStyle(.primary)

            TextField("My vision board...", text: $renameText)
                .textFieldStyle(IntentionTextFieldStyle())
                .padding(.horizontal, 40)
                .focused($isFocused)
                .onAppear {
                    isFocused = true
                }

            HStack {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(SFSymbolButtonStyle(rotateInTrigonometricDirection: true))
                .padding(.trailing, 20)

                Button {
                    board.name = renameText
                    onDismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(SFSymbolButtonStyle())
                .disabled(renameText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.top, -8)
        }
    }
}

