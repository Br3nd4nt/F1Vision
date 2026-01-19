//
//  TeamRadio.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct TeamRadio: Codable {
    let captures: [String: TeamRadioCapture]
}

struct TeamRadioCapture: Codable {
    let path: String
    let racingNumber: String
    let utc: String
}
