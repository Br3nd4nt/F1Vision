//
//  RaceProtocol.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Foundation

protocol RaceProtocol {
    func getRaceData() async throws -> RaceData?
    func getCurrentSnapshot() async throws -> RaceSnapshot?
    func getDriverStates(for lap: Int) async throws -> [DriverState]
    func getDriverState(for driverId: String, lap: Int) async throws -> DriverState?
}
