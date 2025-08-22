//
//  TrackViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Foundation
import Puppy

final class TrackViewModel {
    private let trackService: TrackProtocol = Dependencies.shared.track
    private let logger: Puppy = Dependencies.shared.logger

    @Published var trackData: TrackLayoutModel?

    init() {
        Task {
            do {
                try await getTrackData()
                guard let data = trackData else {
                    throw TrackServiceError.noData
                }
                logger.info("Got track data")
                logger.debug("Track points count: \(String(describing: data))")
            } catch {
                logger.error("Failed getting track data: \(error)")
            }
        }
    }

    func getTrackData() async throws {
        trackData = try await trackService.getTrackData()
    }
}
