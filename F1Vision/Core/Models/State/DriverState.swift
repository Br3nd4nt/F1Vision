//
//  DriverState.swift
//  F1Vision
//
//  Created by br3nd4nt on 18.02.2026.
//

import Foundation

struct DriverMiniSegment: Codable, Hashable, Sendable {
    let sector: Int
    let segment: Int
    let status: Int
}

struct DriverState: Codable {
    var position: Int
    var inPit: Bool
    var diffToFastest: String?
    var diffToAhead: String?
    var currentMiniSegment: DriverMiniSegment?
    var trackProgress: Double?
    // sectorIndex -> segmentIndex -> status
    var miniSegments: [Int: [Int: Int]]
}

enum DriverStateFields: String, CaseIterable {
    case Position
    case InPit
    case TimeDiffToFastest
    case GapToLeader
    case TimeDiffToPositionAhead
    case IntervalToPositionAhead
}
