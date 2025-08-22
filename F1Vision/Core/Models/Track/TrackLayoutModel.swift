//
//  TrackLayoutModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Foundation

struct TrackLayoutModel: Codable, CustomStringConvertible {
    let id: String
    let name: String
    let length: Double
    let points: [TrackPoint]
    let boundingBox: BoundingBox
    let startFinishLine: StartFinishLine

    var description: String {
        "id: \(id) name: \(name), length: \(length), points count: \(points.count), boundingBox: \(boundingBox)"
    }
}
