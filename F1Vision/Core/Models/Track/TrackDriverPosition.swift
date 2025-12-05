//
//  TrackDriverPosition.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import Foundation
import UIKit

struct TrackDriverPosition: Identifiable {
    var id = UUID()

    let name: String
    let point: CGPoint
    let color: UIColor
}
