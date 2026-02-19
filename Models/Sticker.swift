//
//  Sticker.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import SwiftData
import UIKit

@Model
final class Sticker {
    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage) var imageData: Data?
    /// Small pre-downsampled thumbnail for fast display in the catalog.
    @Attribute(.externalStorage) var thumbnailData: Data?
    var createdAt: Date
    
    var uiImage: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
    
    init(imageData: Data, thumbnailData: Data? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.imageData = imageData
        self.thumbnailData = thumbnailData
    }
}
