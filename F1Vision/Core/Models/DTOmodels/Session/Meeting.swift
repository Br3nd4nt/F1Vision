//
//  Meeting.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct Meeting: Codable {
    let Circuit: MeetingCircuitInfo
    let Country: MeetingCountryInfo
    let Key: Int
    let Location: String
    let Name: String
    let Number: Int
    let OfficialName: String
}

struct MeetingCircuitInfo: Codable {
    let Key: Int
    let ShortName: String
}

struct MeetingCountryInfo: Codable {
    let Code: String
    let Key: Int
    let Name: String
}
