//
//  TrackLayout.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

struct TrackLayout: Codable {
    let track_name: String
    let track_points: [TrackPoint]
    let world_bounds: TrackBoundBox
}
