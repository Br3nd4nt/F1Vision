//
//  DriverState.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

struct DriverState: Codable, Identifiable {
    var id: String { driverId.code }
    let driverId: DriverInfo
    let lap: Int
    let position: Int
    let distance: Double
    let speed: Double
    let sector: Int
    let intervalToLeader: Double?
    let intervalToAhead: Double?
    let pitStatus: Bool
    let drsActive: Bool
    let tyre: TyreState
}
