//
//  TeamChampionshipPrediction.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct TeamChampionshipPrediction: Codable {
    let currentPoints: Double
    let currentPosition: Int
    let predictedPoints: Double
    let predictedPosition: Int
    let teamName: String
}
