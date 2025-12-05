//
//  DriverTableEntry.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import Foundation
import UIKit
import SwiftUI

struct DriverTableEntry: Comparable, Identifiable {
    var id = UUID()
    let name: String
    let position: Int
    let speed: Double
    let gear: Int
    let color: UIColor
    let interval: Double?
    var leader: Double?
    let tyre: Int

    var positionString: String {
        String(position)
    }

    var speedSring: String {
        String(Int(speed))
    }

    var gearString: String {
        String(gear)
    }

    var primeColor: Color {
        Color(cgColor: color.cgColor)
    }

    init(_ state: DriverState, color: UIColor) {
        self.name = state.code
        self.position = state.position
        self.speed = state.speed
        self.gear = state.gear
        self.color = color
        self.interval = state.rel_dist
        self.leader = state.rel_dist
        self.tyre = state.tyre
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.position < rhs.position
    }
}
