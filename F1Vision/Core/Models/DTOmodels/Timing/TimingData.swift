//
//  TimingData.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.02.2026.
//

struct TimingData: Codable {
    let Lines: [String: TimingDataLine]
    let Withheld: Bool?
}

struct TimingDataLine: Codable {
    let InPit: Bool?
    let NumberOfLaps: Int?
    let NumberOfPitStops: Int?
    let PitOut: Bool?
    let Position: String
    let BestLapTime: BestLapTime?
    let TimeDiffToFastest: String?
    let GapToLeader: String?
    let TimeDiffToPositionAhead: String?
    let IntervalToPositionAhead: TimingInterval?
    let Sectors: [TimingSector]?
}

struct TimingInterval: Codable {
    let Catching: Bool
    let Value: String
}

struct TimingSector: Codable {
    let Segments: [TimingSegment]?
}

struct TimingSegment: Codable {
    let Status: Int?
}


struct BestLapTime: Codable {
    let Lap: Int?
    let Value: String?
}
