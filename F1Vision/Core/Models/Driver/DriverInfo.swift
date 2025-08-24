//
//  DriverInfo.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

struct DriverInfo: Codable {
    let id: String // example: "HAM44"
    let name: String
    let code: String
    let number: Int
    let team: String
    let teamColorHex: String
    let country: String
}
