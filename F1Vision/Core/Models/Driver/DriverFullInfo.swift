//
//  DriverFullInfo.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct DriverFullInfo: Codable {
    let broadcastName: String
    let countryCode: String
    let firstName: String
    let fullName: String
    let headshotUrl: String
    let lastName: String
    let line: Int
    let raceNumber: String
    let reference: String
    let teamColor: String
    let teamName: String
    let tla: String
}
