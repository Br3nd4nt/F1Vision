//
//  Position.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.01.2026.
//

import Foundation

struct Position: Codable {
    var Position: [PositionSnapshot]
}

struct PositionSnapshot: Codable {
    let Timestamp: String
    let Entries: [String: CarPosition]
}

struct CarPosition: Codable {
    let Status: String
    let X: Int
    let Y: Int
    let Z: Int
}
