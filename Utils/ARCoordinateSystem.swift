//
//  ARCoordinateSystem.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 14/02/2026.
//

import Foundation
import simd

/// Pure coordinate transformation utilities for AR positioning
/// All functions are stateless and easily testable
struct ARCoordinateSystem {
    
    /// Extracts position from a transform matrix
    static func extractPosition(from transform: simd_float4x4) -> SIMD3<Float> {
        SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }
    
    /// Computes the offset between two positions
    static func computeOffset(from initial: SIMD3<Float>, to final: SIMD3<Float>) -> SIMD3<Float> {
        final - initial
    }
    
    /// Applies an offset to a transform matrix's position
    static func applyOffset(_ offset: SIMD3<Float>, to transform: simd_float4x4) -> simd_float4x4 {
        var result = transform
        result.columns.3.x += offset.x
        result.columns.3.y += offset.y
        result.columns.3.z += offset.z
        return result
    }
    
    /// Computes the world position by applying a stored offset to the initial camera transform
    static func computeWorldPosition(
        initialCameraTransform: simd_float4x4,
        storedOffset: SIMD3<Float>
    ) -> simd_float4x4 {
        applyOffset(storedOffset, to: initialCameraTransform)
    }
}
