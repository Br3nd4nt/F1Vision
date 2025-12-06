//
//  TrackBoundBox.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import Foundation

struct TrackBoundBox: Codable {
    let x_min: Double
    let x_max: Double
    let y_min: Double
    let y_max: Double

    var trackWidth: Double {
        x_max - x_min
    }

    var trackHeight: Double {
        y_max - y_min
    }

    var trackAspectRatio: Double {
        trackHeight / trackWidth
    }

    func getScale(for size: CGSize) -> Double {
        if size.height / size.width > trackAspectRatio {
            return size.width / trackWidth
        }
        return size.height / trackHeight
    }
}
