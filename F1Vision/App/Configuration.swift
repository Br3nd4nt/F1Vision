//
//  Configuration.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

struct Configuration {
    static let debugMode = false
    static let zoom = 0.95
    private static let raceName: Race = .defaultCase

    static var trackMockDataset: String {
        if raceName == .defaultCase {
            return "track_layout"
        }
        return "\(raceName.rawValue)_track_layout"
    }

    static var raceMockDataset: String {
        if raceName == .defaultCase {
            return "race_data"
        }
        return "\(raceName.rawValue)_2024_race_data"
    }
}

enum Race: String {
    case monaco
    case defaultCase
}
