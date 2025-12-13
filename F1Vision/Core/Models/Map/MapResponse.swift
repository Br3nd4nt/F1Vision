//
//  MapResponse.swift
//  F1Vision
//
//  Created by br3nd4nt on 13.12.2025.
//

import Foundation

struct MapResponse: Codable {
    // Bahrain does not have them
    let corners: [MapCorner]?
    // structure is the same as map corner, so just reusing the structure for useless (?) part of response
    let marshalLights: [MapCorner]?
    // same goes here
    let marshalSectors: [MapCorner]?
    let candidateLap: CandidateLap
    let circuitKey: Int
    let circuitName: String
    let countryIocCode: String
    let countryKey: Int
    let countryName: String
    let location: String
    let meetingKey: String?
    let meetingName: String?
    let meetingOfficialName: String?
    let raceDate: String
    let rotation: Int // ?
    let round: Int
//    let trackPositionTime: [Double]?
    let x: [Double]
    let y: [Double]
    let year: Int
}
