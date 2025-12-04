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

    private enum CodingKeys: String, CodingKey {
        case type
        case data
    }

    private enum MessageType: String, Codable {
        case trackLayout
        case snapshot
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        switch type {
        case .trackLayout:
            Self.logger.debug("decoding as TrackLayout")
            let data = try container.decode(TrackLayout.self, forKey: .data)
            self = .trackLayout(data)
        case .snapshot:
            Self.logger.debug("decoding as RaceSnapshot")
            let data = try container.decode(RaceSnapshot.self, forKey: .data)
            self = .raceSnapshot(data)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .raceSnapshot(let value):
            try container.encode(MessageType.snapshot, forKey: .type)
            try container.encode(value, forKey: .data)
        case .trackLayout(let value):
            try container.encode(MessageType.trackLayout, forKey: .type)
            try container.encode(value, forKey: .data)
        }
    }
}
