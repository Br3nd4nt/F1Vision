//
//  RaceMock.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Foundation

final class RaceMock: RaceProtocol {
    private let json: JSONDataProtocol = Dependencies.shared.jsonDataService
    private var raceData: RaceData?

    func getRaceData() async throws -> RaceData? {
        if let data = raceData {
            return data
        }

        raceData = json.loadJSON(filename: Configuration.raceMockDataset, as: RaceData.self)
        return raceData
    }

    func getCurrentSnapshot() async throws -> RaceSnapshot? {
        guard let data = try await getRaceData() else {
            throw RaceServiceError.noData
        }

        return data.raceSnapshots.first
    }

    func getDriverStates(for lap: Int) async throws -> [DriverState] {
        guard let data = try await getRaceData() else {
            throw RaceServiceError.noData
        }

        let snapshotsForLap = data.raceSnapshots.filter { $0.lap == lap }

        guard let snapshot = snapshotsForLap.first else {
            throw RaceServiceError.invalidLap
        }

        return snapshot.driverStates
    }

    func getDriverState(for driverId: String, lap: Int) async throws -> DriverState? {
        let driverStates = try await getDriverStates(for: lap)
        return driverStates.first { $0.driverId.id == driverId }
    }
}
