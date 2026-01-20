//
//  TopThree.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct TopThree: Codable {
    let lines: [TopThreeLine]
    let withheld: Bool?
}

struct TopThreeLine: Codable {
    let broadcastName: String?
    let diffToAhead: String
    let diffToLeader: String
    let fullName: String?
    let lapState: Int
    let lapTime: String
    let overallFastest: Bool?
    let personalFastest: Bool?
    let position: String?
    let racingNumber: String?
    let showPosition: Bool?
    let team: String?
    let teamColor: String?
    let tla: String?
}
