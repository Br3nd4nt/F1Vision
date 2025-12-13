//
//  WebsocketMessage.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import Puppy

enum WebsocketMessage: Codable {
    private static let logger: Puppy = Dependencies.shared.logger

    case trackLayout(TrackLayout)
    case raceSnapshot(RaceSnapshot)
    case colors([DriverColorDTO])

    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    private enum MessageType: String, Codable {
        case trackLayout
        case snapshot
        case driverColors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        switch type {
        case .trackLayout:
            let data = try container.decode(TrackLayout.self, forKey: .data)
            self = .trackLayout(data)
        case .snapshot:
            let data = try container.decode(RaceSnapshot.self, forKey: .data)
            self = .raceSnapshot(data)
        case .driverColors:
            let data = try container.decode([DriverColorDTO].self, forKey: .data)
            self = .colors(data)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .raceSnapshot(value):
            try container.encode(MessageType.snapshot, forKey: .type)
            try container.encode(value, forKey: .data)
        case let .trackLayout(value):
            try container.encode(MessageType.trackLayout, forKey: .type)
            try container.encode(value, forKey: .data)
        case let .colors(value):
            try container.encode(MessageType.driverColors, forKey: .type)
            try container.encode(value, forKey: .data)
        }
    }
}
