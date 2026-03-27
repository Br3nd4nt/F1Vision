//
//  StintInfo.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct StintInfo: Codable {
    let Compound: String?
    let LapFlags: Int? // ?
    let LapNumber: Int?
    let LapTime: String?
    let New: String? // "true" | "false"
    let StartLaps: Int?
    let TotalLaps: Int?
    let TyresNotChanged: String? // ??? "0"
}
