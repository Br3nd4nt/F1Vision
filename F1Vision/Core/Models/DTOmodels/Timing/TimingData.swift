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

//struct TimingDataLine: Codable { // not full model
//    let gapToLeader: String
//    let inPit: Bool
//    let intervalToPositionAhead: IntervalToPositionAhead
//    let numberOfLaps: Int?
//    let numberOfPitStops: Int?
//    let pitOut: Bool?
//    let position: String
//    let retired: Bool
//}

struct TimingDataLine: Codable { // for testing
    let InPit: Bool?
    let NumberOfLaps: Int?
    let NumberOfPitStops: Int?
    let PitOut: Bool?
    let Position: String
    let BestLapTime: BestLapTime?
    let TimeDiffToFastest: String?
    let TimeDiffToPositionAhead: String?
}

//struct IntervalToPositionAhead: Codable {
//    let catching: Bool
//    let value: String
//}

struct BestLapTime: Codable {
    let Lap: Int?
    let Value: String?
}
