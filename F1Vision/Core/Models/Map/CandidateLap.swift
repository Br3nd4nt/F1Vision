//
//  CandidateLap.swift
//  F1Vision
//
//  Created by br3nd4nt on 13.12.2025.
//

import Foundation

struct CandidateLap: Codable {
    let driverNumber: String
    let lapNumber: Int
    let lapStartDate: String // "lapStartDate": "2025-04-04T02:37:23.383000"
    let lapStartSessionTime: Double
    let lapTime: Double
    let session: String
    let sessionStartTime: Double
}
