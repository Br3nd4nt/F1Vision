//
//  RaceControlMessage.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct RaceControlMessage: Codable {
    let category: String // TODO: redo to enum
    let lap: Int?
    let message: String
    let utc: String
}

struct RaceControlMessages: Codable {
    let messages: [RaceControlMessage]
}
