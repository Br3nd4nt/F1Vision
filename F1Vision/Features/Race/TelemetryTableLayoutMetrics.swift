//
//  TelemetryTableLayoutMetrics.swift
//  F1Vision
//
//  Created by br3nd4nt on 13.03.2026.
//

import UIKit

enum TelemetryTableLayoutMetrics {
    static let horizontalPadding: Double = 10
    static let verticalPadding: Double = 5
    static func fixedWidth(viewModel: RaceViewModel) -> Double {
        let sizingDelegate = TelemetryTableCollectionViewDelegate(viewModel: viewModel)
        let contentInsets = horizontalPadding * 2
        return sizingDelegate.totalColumnsWidth() + contentInsets
    }
}
