//
//  Configuration.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

struct Configuration {
    static let isHitBoxesEnabled = true
    static let zoom = 0.95

    static let trackMockDataset: trackMockDatasets = .baku
}


enum trackMockDatasets: String {
    case suzuka = "suzuka_track_layout"
    case spa = "spa_track_layout"
    case baku = "baku_track_layout"
}
