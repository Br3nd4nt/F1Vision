//
//  DriverTableEntry.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import Foundation

struct DriverTableEntry: Comparable, Identifiable {
    var id = UUID()
    let name: String
    let position: Int
    let speed: Double
    let gear: Int

    var positionString: String {
        String(position)
    }

    var speedSring: String {
        String(Int(speed))
    }

    var gearString: String {
        String(gear)
    }

    init(_ state: DriverState) {
        self.name = state.code
        self.position = state.position
        self.speed = state.speed
        self.gear = state.gear
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.position < rhs.position
    }
}
