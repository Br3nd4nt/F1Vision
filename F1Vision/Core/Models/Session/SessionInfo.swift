//
//  SessionInfo.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct SessionInfo: Codable {
    let ArchiveStatus: ArchiveStatus
    let EndDate: String
    let Key: Int
    let Meeting: Meeting?
}

struct ArchiveStatus: Codable {
    let Status: String
}
