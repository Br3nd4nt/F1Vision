//
//  TimingAppData.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct TimingAppData: Codable {
    let Lines: [String: TimingAppDataLine]
}

struct TimingAppDataLine: Codable {
    let GridPos: String?
    let Line: Int?
    let RacingNumber: String?
    let Stints: [StintInfo]?
}
