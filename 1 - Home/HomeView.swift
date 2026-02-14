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
    
    @Query(sort: \VisionBoard.date, order: .reverse) private var boards: [VisionBoard]
    @State private var path = NavigationPath()
    
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
                    Button(action: createNewBoard) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding()
                
                if boards.isEmpty {
                    ContentUnavailableView(
                        "No Vision Boards",
                        systemImage: "wand.and.stars",
                        description: Text("Create your first AR Vision Board to start manifesting.")
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(boards) { board in
                            NavigationLink(value: board) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(board.name.isEmpty ? "Untitled Board" : board.name)
                                            .font(.headline)
                                        Text(board.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("\(board.objects.count) items")
                                        .font(.caption)
                                        .padding(6)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteBoard)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationDestination(for: VisionBoard.self) { board in
            ARVisionBoardView(board: board)
        }
    }
    
    private func createNewBoard() {
        let newBoard = VisionBoard()
        newBoard.name = "New Board"
        modelContext.insert(newBoard)
        // Navigation is handled by the user tapping, or we can programmatically push if we bind the path.
        // For now, let's just insert it.
    }
    
    private func deleteBoard(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(boards[index])
        }
    }
}
