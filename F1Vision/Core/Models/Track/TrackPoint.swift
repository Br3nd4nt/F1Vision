//
//  TrackPoint.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Foundation

struct TrackPoint: Codable {
    let x: Double
    let y: Double
    let distance: Double

    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }

    // Calculate distance from start of track
    func distanceFromStart() -> Double {
        distance
    }

}
