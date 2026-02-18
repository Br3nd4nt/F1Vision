//
//  ChampionshipPrediction.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct ChampionshipPrediction: Codable {
    let drivers: [String: DriverChampionshipPrediction]
    let teams: [String: TeamChampionshipPrediction]
}
