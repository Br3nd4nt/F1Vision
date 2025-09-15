//
//  RaceViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class RaceViewModel: ObservableObject {
    // MARK: - Published Properties


    @Published var raceData: RaceData?
    @Published var currentSnapshot: RaceSnapshot?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    // Real-time update properties
    private var updateTimer: Timer?
    private var currentSnapshotIndex = 0
    private var cancellables = Set<AnyCancellable>()

    private let raceService: RaceProtocol = Dependencies.shared.race
    private var trackViewModel: TrackViewModel?

    // MARK: - Init

    init() {
        loadRaceData()
    }

    deinit {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    // MARK: - Track Integration

    func setTrackViewModel(_ trackViewModel: TrackViewModel) {
        self.trackViewModel = trackViewModel
        // Update track with current driver positions if available
        if let snapshot = currentSnapshot {
            trackViewModel.updateDriverPositions(snapshot.driverStates)
        }
    }

    // MARK: - Data Loading

    func loadRaceData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                if let data = try await raceService.getRaceData() {
                    await MainActor.run {
                        self.raceData = data
                        self.currentSnapshotIndex = 0
                    }

                    if let snapshot = try await raceService.getCurrentSnapshot() {
                        await MainActor.run {
                            self.currentSnapshot = snapshot
                            self.startRealTimeUpdates()
                        }
                    } else {
                        await MainActor.run {
                            self.errorMessage = "Failed to load current snapshot"
                        }
                    }
                } else {
                    await MainActor.run {
                        self.errorMessage = "Failed to load race data"
                    }
                }
            } catch {
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

    // MARK: - Real-time Updates

    private func startRealTimeUpdates() {
        stopRealTimeUpdates()

        // Update every 2 seconds to simulate real-time data
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateToNextSnapshot()
            }
        }
    }

    private func stopRealTimeUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    private func updateToNextSnapshot() {
        guard let raceData else {
            return
        }

        let nextIndex = (currentSnapshotIndex + 1) % raceData.raceSnapshots.count
        currentSnapshotIndex = nextIndex

        let newSnapshot = raceData.raceSnapshots[nextIndex]
        currentSnapshot = newSnapshot

        // Update track view with new driver positions
        trackViewModel?.updateDriverPositions(newSnapshot.driverStates)
    }
}
