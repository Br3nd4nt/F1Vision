//
//  TrackPoint.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

struct TrackPoint: Codable, Comparable {
    let x: Double
    let y: Double
    let x_inner: Double
    let y_inner: Double
    let x_outer: Double
    let y_outer: Double
    let distance: Double

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.distance < rhs.distance
    }

    // for binary search
    init(with distance: Double) {
        x = 0
        y = 0
        x_inner = 0
        y_inner = 0
        x_outer = 0
        y_outer = 0
        self.distance = distance
    }
}
