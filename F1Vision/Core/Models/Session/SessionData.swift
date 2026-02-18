//
//  SessionData.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct SessionDataSeries: Codable {
    let lap: Int?
    let sessionStatus: String?
    let utc: String
}

struct SessionData: Codable {
    let statusSeries: [String: SessionDataSeries]
}
