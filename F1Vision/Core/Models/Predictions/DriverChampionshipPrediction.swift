//
//  DriverChampionshipPrediction.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct DriverChampionshipPrediction: Codable {
    let currentPoints: Double
    let currentPosition: Int
    let predictedPoints: Double
    let predictedPosition: Int
    let racingNumber: String
}
