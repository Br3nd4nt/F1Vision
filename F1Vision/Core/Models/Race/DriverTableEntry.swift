//
//  DriverTableEntry.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import Foundation
import SwiftUI
import UIKit

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
        name = state.code
        position = state.position
        speed = state.speed
        gear = state.gear
        self.color = color
        interval = state.rel_dist
        leader = state.rel_dist
        tyre = state.tyre
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.position < rhs.position
    }
}
