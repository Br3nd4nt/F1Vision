//
//  RaceMock.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Foundation
import Puppy

final class RaceMock: RaceProtocol {
    private let json: JSONDataProtocol = Dependencies.shared.jsonDataService
    private var raceData: RaceData?
    private let logger: Puppy = Dependencies.shared.logger

    func getRaceData() async throws -> RaceData? {
        if let data = raceData {
            logger.debug("RaceMock: cache hit snapshots=\(data.raceSnapshots.count)")
            return data
        }

        raceData = json.loadJSON(filename: Configuration.raceMockDataset, as: RaceData.self)
        if let raceData {
            logger.info("RaceMock: loaded race data")
            logger.debug("snapshots=\(raceData.raceSnapshots.count)")
        } else {
            logger.error("RaceMock: failed to load race data")
        }
        return raceData
    }

    func getCurrentSnapshot() async throws -> RaceSnapshot? {
        guard let data = try await getRaceData() else {
            throw RaceServiceError.noData
        }
        let snapshot = data.raceSnapshots.first
        if let s = snapshot {
            logger.debug("currentSnapshot.lap=\(s.lap) drivers=\(s.driverStates.count)")
        } else {
            logger.error("No snapshots available")
        }
        return snapshot
    }

    func getDriverStates(for lap: Int) async throws -> [DriverState] {
        guard let data = try await getRaceData() else {
            throw RaceServiceError.noData
        }

        let snapshotsForLap = data.raceSnapshots.filter { $0.lap == lap }

        guard let snapshot = snapshotsForLap.first else {
            throw RaceServiceError.invalidLap
        }
        logger.debug("lap=\(lap) drivers=\(snapshot.driverStates.count)")
        return snapshot.driverStates
    }

    func getDriverState(for driverId: String, lap: Int) async throws -> DriverState? {
        let driverStates = try await getDriverStates(for: lap)
        let driver = driverStates.first { $0.driverId.id == driverId }
        if let driver {
            logger.debug("driverId=\(driverId) lap=\(lap) pos=\(driver.position)")
        } else {
            logger.error("driverId not found driverId=\(driverId) lap=\(lap)")
        }
        return driver
    }
}
