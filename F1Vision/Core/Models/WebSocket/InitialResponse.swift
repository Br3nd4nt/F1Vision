//
//  InitialResponse.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct InitialResponse: Codable {
    let championshipPrediction: ChampionshipPrediction
    let driverList: [String: DriverFullInfo]
    let extrapolatedClock: ExtrapolatedClock
    let heartbeat: Heartbeat
    let lapCount: LapCount
    let positionZ: String // zlib encoded
    let raceControlMessages: RaceControlMessages
    let sessionData: SessionData
    let seessionInfo: SessionInfo
    let sessionStatus: SessionStatus
    let teamRadio: TeamRadio
    let timingAppData: TimingAppData
    let timingStats: TimingStats
    let topThree: TopThree
    let trackStatus: TrackStatus
    let weatherData: WeatherData
}
