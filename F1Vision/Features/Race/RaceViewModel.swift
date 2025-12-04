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
    private let logger: Puppy = Dependencies.shared.logger

    private var cancellables = Set<AnyCancellable>()
    private let socketService: SocketService

    @Published var isLoaded = false
    @Published var drivers: [DriverTableEntry] = []

    init(_ socketService: SocketService) {
        self.socketService = socketService
        self.socketService.$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStandings()
            }
            .store(in: &cancellables)
    }

    private func updateStandings() {
        guard let snapshot = socketService.snapshot else {
            logger.error("Called update standings without snapshot")
            return
        }
        isLoaded = true
        drivers = snapshot.drivers.map {
            DriverTableEntry($0)
        }
        .sorted()
    }
}
