//
//  Configuration.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

import Foundation
import Puppy

struct Configuration {
    private static let logger: Puppy = Dependencies.shared.logger

    private static var socketAddress = "127.0.0.1"

    static var socketURL: URL {
        let url = URL(string: "ws://\(socketAddress):8080/ws")
        if let url {
            return url
        }
        logger.error("Error creating URL")
        fatalError("Error creating URL")
    }

    static let debugMode = false
    static let zoom = 0.95
    private static let raceName: Race = .defaultCase

    static var trackMockDataset: String {
        if raceName == .defaultCase {
            return "track_layout"
        }
        return "\(raceName.rawValue)_track_layout"
    }

    static var raceMockDataset: String {
        if raceName == .defaultCase {
            return "race_data"
        }
        return "\(raceName.rawValue)_2024_race_data"
    }
}

enum Race: String {
    case monaco
    case defaultCase
}
