//
//  DriverColor.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import SwiftUI

struct DriverColorDTO: Codable {
    let driver: String
    let hex_color: String
}

struct DriverColor {
    let code: String
    let color: UIColor

    init(_ dto: DriverColorDTO) {
        code = dto.driver
        color = UIColor(hex: dto.hex_color)
    }
}
