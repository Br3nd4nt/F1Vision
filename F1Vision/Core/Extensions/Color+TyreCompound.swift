//
//  Color+TyreCompound.swift
//  F1Vision
//
//  Created by br3nd4nt on 08.09.2025.
//

import SwiftUI

extension Color {
    init(compound: TyreCompound) {
        switch compound {
        case .soft:
            self = .red
        case .medium:
            self = .yellow
        case .hard:
            self = .white
        case .intermediate:
            self = .green
        case .wet:
            self = .blue
        case .unknown:
            self = .gray
        }
    }
}
