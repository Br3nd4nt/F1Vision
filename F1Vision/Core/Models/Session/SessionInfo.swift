//
//  SessionInfo.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct SessionInfo: Codable {
    let archiveStatus: ArchiveStatus
    let endDate: String
    let key: Int
    let meeting: Meeting?
}

struct ArchiveStatus: Codable {
    let status: String
}
