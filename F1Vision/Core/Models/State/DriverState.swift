//
//  DriverState.swift
//  F1Vision
//
//  Created by br3nd4nt on 18.02.2026.
//

import Foundation

struct DriverState: Codable {
    var position: Int
    var inPit: Bool
    var diffToFastest: Double
    var diffToAhead: Double
}

enum DriverStateFields: String, CaseIterable {
    case Position
    case InPit
    case TimeDiffToFastest
    case TimeDiffToPositionAhead
}
