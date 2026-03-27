//
//  TireStint.swift
//  F1Vision
//
//  Created by br3nd4nt on 27.03.2026.
//

import UIKit

struct TireStint: Codable, Identifiable {
    var totalLaps: Int
    var compound: String // "SOFT" | "MEDIUM" | "HARD" | "INTERMEDIATE" | "WET" | "UNDEFINED"
    var newCompound: Bool // true | false
    
    var stintNumber: Int
    
    var id: String { "\(compound)|\(newCompound)|\(totalLaps)|\(stintNumber)" }
    
    var letter: Character {
        switch compound {
            case "SOFT": return "S"
            case "MEDIUM": return "M"
            case "HARD": return "H"
            case "INTERMEDIATE": return "I"
            case "WET": return "W"
            default: return "?"
        }
    }
    
    var color: UIColor {
        switch compound {
        case "SOFT": return .softTire
        case "MEDIUM": return .mediumTire
        case "HARD": return .hardTire
        case "INTERMEDIATE": return .intermediateTire
        case "WET": return .wetTire
        default: return .gray
        }
    }
}

extension TireStint {
    init(_ info: StintInfo, stintNumber: Int) {
        self.totalLaps = info.TotalLaps ?? 0
        self.compound = info.Compound?.uppercased() ?? "UNDEFINED"
        self.newCompound = info.New == "true"
        self.stintNumber = stintNumber
    }
    
    init() {
        self.totalLaps = 0
        self.compound = "UNDEFINED"
        self.newCompound = true
        self.stintNumber = 0
    }
}
