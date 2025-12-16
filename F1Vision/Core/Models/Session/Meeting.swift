//
//  Meeting.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct Meeting: Codable {
    let circuit: MeetingCircuitInfo
    let country: MeetingCountryInfo
    let key: Int
    let location: String
    let name: String
    let number: Int
    let officialName: String
}

struct MeetingCircuitInfo: Codable {
    let key: Int
    let shortName: String
}

struct MeetingCountryInfo: Codable {
    let code: String
    let key: Int
    let name: String
}
