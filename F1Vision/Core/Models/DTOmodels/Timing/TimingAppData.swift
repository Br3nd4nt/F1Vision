//
//  TimingAppData.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct TimingAppData: Codable {
    let lines: [String: TimingAppDataLine]
}

struct TimingAppDataLine: Codable {
    let gridPos: String?
    let line: Int?
    let racingNumber: String?
    let stints: [String: StintInfo]?
}
