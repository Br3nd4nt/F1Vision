//
//  TrackProtocol.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

protocol TrackProtocol {
    func getTrackData() async throws -> TrackLayoutModel?
}
