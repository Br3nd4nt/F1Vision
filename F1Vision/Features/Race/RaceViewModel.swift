//
//  RaceViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Combine
import Foundation
import Puppy
import SwiftUI

@MainActor
final class RaceViewModel: ObservableObject {
    private let logger: Puppy = Dependencies.shared.logger

    private var cancellables = Set<AnyCancellable>()
    private let socketService: SocketService

    @Published var isLoaded = false
    @Published var drivers: [DriverTableEntry] = []
    
    let numberOfTableColumns = 3

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
            return
        }
        isLoaded = true
        drivers = snapshot.drivers.map {driver in
            let color = socketService.driverColors?.first { driverColor in
                driverColor.code == driver.code
            }?.color ?? UIColor.gray
            return DriverTableEntry(driver, color: color)
        }
        .sorted()
    }
}
