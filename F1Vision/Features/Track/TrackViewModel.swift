//
//  TrackViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Foundation
import Puppy

class TrackViewModel {
    private let trackService: TrackProtocol
    private let logger: Puppy

    @Published var trackData: TrackLayoutModel = .init(points: [])

    init(
        trackService: TrackProtocol = Dependencies.shared.track,
        logger: Puppy = Dependencies.shared.logger
    ) {
        self.trackService = trackService
        self.logger = logger

        Task {
            do {
                try await getTrackData()
                logger.info("Got track data")
                logger.debug("Track points count: \(trackData.points.count)")
            } catch {
                logger.error("Failed getting track data: \(error)")
            }
        }

    }

    func getTrackData() async throws {
        trackData = try await trackService.getTrackPoints()
    }
}
