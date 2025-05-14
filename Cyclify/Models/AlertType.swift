//
//  AlertType.swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/30/25.
//

import Foundation

enum IntensityLevel: Int {
    case veryLow = 1
    case low = 2
    case medium = 3
    case high = 4
    case veryHigh = 5

    var description: String {
        switch self {
        case .veryLow: return "very low"
        case .low: return "low"
        case .medium: return "medium"
        case .high: return "high"
        case .veryHigh: return "very high"
        }
    }

    var emphasisModifier: String {
        switch self {
        case .veryLow: return "Just a slight"
        case .low: return "A little"
        case .medium: return "Moderate"
        case .high: return "Significant"
        case .veryHigh: return "Severe"
        }

    }
}

enum AlertType: String, CaseIterable {
    case leanLeft = "LL"
    case leanRight = "LR"
    case leanForward = "LF"
    case leanBackward = "LB"
    case pressureRight = "PR"
    case pressureLeft = "PL"

    var name: String {
        switch self {
        case .leanLeft: return "Leaning Left"
        case .leanRight: return "Leaning Right"
        case .leanForward: return "Leaning Forward"
        case .leanBackward: return "Leaning Backward"
        case .pressureRight: return "Right Handlebar Pressure"
        case .pressureLeft: return "Left Handlebar Pressure"
        }
    }

    func message(forIntensity intensity: Int) -> String {
        let level: IntensityLevel
        
        if intensity < 20 {
            level = .veryLow
        } else if intensity < 40 {
            level = .low
        } else if intensity < 60 {
            level = .medium
        } else if intensity < 80 {
            level = .high
        } else {
            level = .veryHigh
        }

        switch self {
        case .leanLeft:
            return "\(level.emphasisModifier) lean to the left detected. Try to center your posture."
        case .leanRight:
            return "\(level.emphasisModifier) lean to the right detected. Try to stay balanced."
        case .leanForward:
            return "\(level.emphasisModifier) forward lean detected. Relax your shoulders and sit upright."
        case .leanBackward:
            return "\(level.emphasisModifier) backward lean detected. Bring your body slightly forward."
        case .pressureRight:
            return "\(level.emphasisModifier) pressure on the right handlebar. Distribute your weight evenly."
        case .pressureLeft:
            return "\(level.emphasisModifier) pressure on the left handlebar. Balance your grip."
        }
    }
}
