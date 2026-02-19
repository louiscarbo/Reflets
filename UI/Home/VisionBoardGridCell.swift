//
//  VisionBoardGridCell.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 17/02/2026.
//

import SwiftUI

struct VisionBoardGridCell: View {
    let board: VisionBoard
    
    private var displayObjects: [ARObject] {
        var uniqueObjects: [ARObject] = []
        var seenTypes: Set<String> = []
        
        for obj in board.objects {
            let identifier: String
            if obj.type == .image, let stickerId = obj.sticker?.id.uuidString {
                identifier = "sticker_\(stickerId)"
            } else {
                identifier = "type_\(obj.type.rawValue)"
            }
            
            if !seenTypes.contains(identifier) {
                uniqueObjects.append(obj)
                seenTypes.insert(identifier)
                
                if uniqueObjects.count >= 3 {
                    break
                }
            }
        }
        
        return uniqueObjects
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if displayObjects.isEmpty {
                    // Show sparkle if no objects
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                } else {
                    // Show up to 3 objects in an interlacing style
                    ZStack {
                        ForEach(Array(displayObjects.enumerated()), id: \.element.id) { index, object in
                            ObjectPreviewView(object: object, index: index)
                        }
                    }
                    .padding(20)
                }
            }
            .frame(height: 120)
            
            // Board name with IntentionButton style
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 255/255, green: 216/255, blue: 244/255),
                                Color(red: 255/255, green: 189/255, blue: 125/255),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                
                Capsule()
                    .stroke(Color.black.opacity(0.1), lineWidth: 3)
                    .blur(radius: 1)
                    .clipShape(Capsule())
                
                Text(board.name.isEmpty ? "Untitled Board" : board.name)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .fontWidth(.expanded)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .font(.title3)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
            }
            .offset(y: -5)
            .rotationEffect(.degrees(.random(in: -5...5)))
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(8)
    }
}

struct ObjectPreviewView: View {
    let object: ARObject
    let index: Int
    
    private var rotation: Angle {
        switch index {
        case 0: return .degrees(-15)
        case 1: return .degrees(15)
        case 2: return .degrees(0)
        default: return .degrees(0)
        }
    }
    
    private var offset: CGSize {
        switch index {
        case 0: return CGSize(width: -50, height: 15)
        case 1: return CGSize(width: 50, height: 15)
        case 2: return CGSize(width: 0, height: -15)
        default: return .zero
        }
    }
    
    private var objectColor: Color {
        Color(red: object.red, green: object.green, blue: object.blue)
    }
    
    var body: some View {
        Group {
            if object.type == .image, let sticker = object.sticker, let imageData = sticker.imageData {
                // Show sticker image
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 80, maxHeight: 80)
                        .padding(3)
                        .layerEffect(
                            ShaderLibrary.outline(.float(6.0)),
                            maxSampleOffset: CGSize(width: 6, height: 6)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
                }
            } else {
                // Show SF Symbol for shapes
                Image(systemName: object.type.SFSymbolName + ".fill")
                    .font(.system(size: 70))
                    .foregroundStyle(objectColor)
                    .padding(3)
                    .layerEffect(
                        ShaderLibrary.outline(.float(6.0)),
                        maxSampleOffset: CGSize(width: 6, height: 6)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
            }
        }
        .rotationEffect(rotation)
        .offset(offset)
        .zIndex(Double(index))
    }
}
