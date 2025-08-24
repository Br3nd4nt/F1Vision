//
//  RaceViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Foundation
import SwiftUI
import Puppy

@MainActor
final class RaceViewModel: ObservableObject {
    private let logger: Puppy = Dependencies.shared.logger

    @Published var raceData: RaceData?
    @Published var currentSnapshot: RaceSnapshot?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let raceService: RaceProtocol = Dependencies.shared.race

    init() {
        loadRaceData()
    }

    func loadRaceData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                if let data = try await raceService.getRaceData() {
                    logger.info("Got race data for \(data.raceId)")
                    logger.debug(String(describing: data))

                    await MainActor.run {
                        self.raceData = data
                    }

                    if let snapshot = try await raceService.getCurrentSnapshot() {
                        logger.info("Got current snapshot for \(snapshot.timestamp)")
                        logger.debug(String(describing: data))

                        await MainActor.run {
                            self.currentSnapshot = snapshot
                        }

                        let lap1Drivers = try await raceService.getDriverStates(for: 1)

                        if let firstDriver = lap1Drivers.first {
                            let specificDriver = try await raceService.getDriverState(for: firstDriver.driverId.id, lap: 1)
                        }
                    } else {
                        await MainActor.run {
                            self.errorMessage = "Failed to load current snapshot"
                        }
                    }
                } else {
                    logger.error("Failed to load race data")
                    await MainActor.run {
                        self.errorMessage = "Failed to load race data"
                    }
                }
            } catch {
                logger.error("Error loading race data: \(error)")
                await MainActor.run {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
            }

            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    func refreshData() {
        loadRaceData()
    }
}
