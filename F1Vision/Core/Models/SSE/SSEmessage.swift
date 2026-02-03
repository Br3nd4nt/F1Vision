//
//  InitialResponse.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct SSEmessage: Codable {
    var championshipPrediction: ChampionshipPrediction?
    var driverList: [String: DriverFullInfo]?
    var extrapolatedClock: ExtrapolatedClock?
    var heartbeat: Heartbeat?
    var lapCount: LapCount?
    var carDataZ: String?
    var positionZ: String? // zlib encoded
    var raceControlMessages: RaceControlMessages?
    var sessionData: SessionData?
    var sessionInfo: SessionInfo?
    var sessionStatus: SessionStatus?
    var teamRadio: TeamRadio?
    var timingAppData: TimingAppData?
    var timingStats: TimingStats?
    var topThree: TopThree?
    var trackStatus: TrackStatus?
    var weatherData: WeatherData?
}
