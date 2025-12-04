//
//  TrackPoint.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

struct TrackPoint: Codable {
    let x: Double
    let y: Double
    let x_inner: Double
    let y_inner: Double
    let x_outer: Double
    let y_outer: Double
    let distance: Double
}
