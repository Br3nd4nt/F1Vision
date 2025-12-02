//
//  RaceData.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Foundation

struct RaceData: Codable, CustomStringConvertible {
    let raceId: String
    let trackName: String
    let year: Int
    let totalSnapshots: Int
    let totalDrivers: Int
    let generatedAt: String
    let raceSnapshots: [RaceSnapshot]

    var description: String {
        "raceId: \(raceId) trackName: \(trackName) year: \(year) totalSnapshots: \(totalSnapshots) totalDrivers: \(totalDrivers)"
    }
}

struct RaceSnapshot: Codable, CustomStringConvertible {
    let timestamp: String
    let lap: Int
    var driverStates: [DriverState]

    var description: String {
        "time: \(timestamp) lap: \(lap), driver state count: \(driverStates.count)"
    }
}
