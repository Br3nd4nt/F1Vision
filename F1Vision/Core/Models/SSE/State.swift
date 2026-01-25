//
//  State.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.01.2026.
//

import Foundation

struct State: Codable {
    private static let jsonDecoder = Dependencies.shared.jsonDecoder
    private static let decodingService = Dependencies.shared.zlibDecoder
    
    var position: Position
    let sessionInfo: SessionInfo?
    
    init(_ response: InitialResponse) throws {
        let carData = response.positionZ
        guard let data = Self.decodingService.getBase64Decoded(carData) else {
            throw ZLibDecodingError.base64DecodingFailed
        }
        let inflated = try Self.decodingService.inflate(data)
        position = try Self.jsonDecoder.decode(Position.self, from: inflated)
        guard let info = response.sessionInfo else {
            throw StateError.SessionInfoNotFound
        }
        sessionInfo = info
    }
}

enum StateError: Error {
    case SessionInfoNotFound
}
