//
//  TimingStats.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct TimingStats: Codable {
    let lines: [String: TimingStatsLine]
    let sessionType: String?
    let withheld: Bool?
}

struct TimingStatsLine: Codable {
    let bestSectors: [String: BestSpeedInfo]?
    let bestSpeeds: BestSpeeds?
    let lap: Int?
    let personalBestLapTime: PersonalBestLapTime?
    let racingNumber: String?
}

struct BestSpeeds: Codable {
    let fl: BestSpeedInfo? // finish line (s3 -> s1)
    let i1: BestSpeedInfo? // s1 -> s2
    let i2: BestSpeedInfo? // s2 -> s3
    let st: BestSpeedInfo? // speed trap
}

struct PersonalBestLapTime: Codable {
    let lap: Int?
    let position: Int?
    let value: String?
}
