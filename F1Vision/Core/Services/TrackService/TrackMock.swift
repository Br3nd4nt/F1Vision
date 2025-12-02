//
//  TrackMock.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Puppy

final class TrackMock: TrackProtocol {
    private let json: JSONDataProtocol = Dependencies.shared.jsonDataService
    private let logger: Puppy = Dependencies.shared.logger

    func getTrackData() -> TrackLayoutModel? {
        let result = json.loadJSON(filename: Configuration.trackMockDataset, as: TrackLayoutModel.self)
        if let result {
            logger.info("TrackMock: loaded track layout")
            logger.debug("points=\(result.points.count) name=\(result.trackName)")
        } else {
            logger.error("TrackMock: failed to load track layout")
        }
        return result
    }
}
