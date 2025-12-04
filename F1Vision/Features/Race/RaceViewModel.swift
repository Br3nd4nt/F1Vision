//
//  RaceViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Foundation
import SwiftUI
import Combine
import Puppy

@MainActor
final class RaceViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isLoading = false
    // MARK: - Private Properties

//    private let raceService: RaceProtocol = Dependencies.shared.race
    private var trackViewModel: TrackViewModel?
    private let logger: Puppy = Dependencies.shared.logger

    // MARK: - Init

    init() {
        loadRaceData()
    }

    deinit {
    }

    // MARK: - Track Integration

    func setTrackViewModel(_ trackViewModel: TrackViewModel) {
        self.trackViewModel = trackViewModel
    }

    // MARK: - Data Loading

    func loadRaceData() {
    }

    func refreshData() {
    }

    // MARK: - Real-time Updates

    private func startRealTimeUpdates() {
    }

    private func stopRealTimeUpdates() {
    }

    private func updateToNextSnapshot() {
    }
}
