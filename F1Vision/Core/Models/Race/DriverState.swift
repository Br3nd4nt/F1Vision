//
//  DriverState.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

struct DriverState: Codable {
    let code: String
    let x: Double // redundant
    let y: Double // redundant
    let dist: Double // used to place driver on track
    let lap: Int
    let rel_dist: Double? // can be NaN
    let tyre: Int
    let position: Int
    let speed: Double
    let gear: Int
    let drs: Int
}
