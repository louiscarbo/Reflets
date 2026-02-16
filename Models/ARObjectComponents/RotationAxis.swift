//
//  RotationAxis.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 16/02/2026.
//

import Foundation

enum RotationAxis: String, Codable, CaseIterable {
    case x = "X"
    case y = "Y"
    case z = "Z"
    
    var vector: SIMD3<Float> {
        switch self {
        case .x:
            return SIMD3<Float>(1, 0, 0)
        case .y:
            return SIMD3<Float>(0, 1, 0)
        case .z:
            return SIMD3<Float>(0, 0, 1)
        }
    }
    
    var sfSymbolString: String {
        switch self {
        case .x:
            return "arrow.up"
        case .y:
            return "arrow.left"
        case .z:
            return "arrow.clockwise"
        }
    }
}
