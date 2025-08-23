//
//  Configuration.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

struct Configuration {
    static let isHitBoxesEnabled = true
    static let zoom = 0.95
    private static let raceName: Race = .monza

    static var trackMockDataset: String {
        "\(raceName.rawValue)_track_layout"
    }

    static var raceMockDataset: String {
        "\(raceName.rawValue)_2024_race_data"
    }
}

enum Race: String {
    case suzuka
    case monaco
    case monza
    case spa
}
