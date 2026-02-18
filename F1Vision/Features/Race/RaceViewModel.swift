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
final class RaceViewModel: ObservableObject { // TODO: add same logic with screen size sent as in track view
    private let logger: Puppy = Dependencies.shared.logger

    private var cancellables = Set<AnyCancellable>()
    private let sseService: SSEService
    let emptyCellReuseId = "emptyCellReuseId"

    @Published var isLoaded = false

//    @Published var driversTelemetry: [Int: CarDataChannels] = [:]
    
    private var driversInfo: [Int: DriverFullInfo]?
    private var driversColors: [Int: UIColor]?
    private static let defaultDriverPointColor: UIColor = Configuration.defaultDriverPointColor
    
    // Driver's number: their position
    @Published var driversStates: [Int: DriverState] = [:]

    init(sseService: SSEService) {
        self.sseService = sseService
        
        self.sseService.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.saveDriversInfo(state)
                self?.handleState(state)
                self?.isLoaded = true // ???
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ state: SSEstate?) {
        guard let state else {
            return
        }
        driversStates = state.driversStates

    }
    
    private func saveDriversInfo(_ state: SSEstate?) {
        if driversInfo != nil {
            return
        }
        guard let state, let info = state.driversInfo else {
            return
        }
        driversInfo = info
        logger.info("driver info saved successfully")
        
        var colors = [Int: UIColor]()
        for (driver, info) in info {
            guard let hex = info.TeamColour else {
                continue
            }
            let color = UIColor(hex: hex)
            colors[driver] = color
        }
        driversColors = colors
    }
    
    // MARK: Public methods
    func getDriverColor(_ driver: Int) -> UIColor {
        guard let driversColors else { return Self.defaultDriverPointColor }
        if let color = driversColors[driver] {
            return color
        }
        return Self.defaultDriverPointColor
    }
    
    func getDriverName(_ driver: Int) -> String {
        guard let driversInfo, let d = driversInfo[driver] else { return "-" }
        return d.Tla ?? "-"
    }
}
