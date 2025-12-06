//
//  RaceSnapshot.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

struct RaceSnapshot: Codable {
    let t: Double // time
    let lap: Int
    let drivers: [DriverState]
}
