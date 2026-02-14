//
//  ARObjectType.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 30/10/2024.
//

import Foundation
import SwiftUI

enum ARObjectType: String, Codable, CaseIterable {
    case sphere, cube, cone, cylinder, text, image
    
    var hasCustomColor: Bool {
        switch self {
        case .sphere, .cube, .cone, .cylinder, .text:
            return true
        default:
            return false
        }
    }
    
    var hasCustomText: Bool {
        self == .text
    }
    
    var hasCustomRatio: Bool {
        self == .cone || self == .cylinder
    }
    
    var SFSymbolName: String {
        switch self {
        case .cone: return "cone"
        case .sphere: return "rotate.3d"
        case .cube: return "cube"
        case .cylinder: return "cylinder"
        case .text: return "textformat"
        default: return "questionmark"
        }
    }
}
