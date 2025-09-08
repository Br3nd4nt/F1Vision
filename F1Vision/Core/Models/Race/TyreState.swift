//
//  TyreState.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

import SwiftUICore

struct TyreState: Codable {
    let compound: TyreCompound
    let age: Int
    let fresh: Bool
}
