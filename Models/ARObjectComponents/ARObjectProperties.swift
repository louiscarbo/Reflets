//
//  ARObjectProperties.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 30/10/2024.
//

import Foundation
import SwiftUI

struct ARObjectProperties: Equatable {
    var type: ARObjectType = .sphere
    var color: Color = .yellow
    var metallic: Bool = true
    var text: String = "Hello!"
    var ratio: Float = 2.0
    var opacity: Double = 1.0
    var size: Float = 1.0
    var resizingFactor: Float = 0.3
    var customObject: CustomObject?
}
