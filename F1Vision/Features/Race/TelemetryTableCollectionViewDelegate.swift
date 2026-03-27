//
//  TelemetryTableCollectionViewDelegate.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.12.2025.
//

import Puppy
import UIKit

final class TelemetryTableCollectionViewDelegate: NSObject,
                                                  UICollectionViewDelegate,
                                                  UICollectionViewDelegateFlowLayout {
    private let logger: Puppy = Dependencies.shared.logger
    private let viewModel: RaceViewModel
    
    private enum Column: Int {
        case identity = 0
        case inPit = 1
        case tire = 2
        case intervalAhead = 3
        case internalToFastest = 4
    }
    
    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }

    var columnCount: Int { 5 }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // Height is managed by the collection view's constraints (it can resize with the window).
        // Each cell should simply match the available row height as computed by the layout.
        let height = collectionView.bounds.inset(by: collectionView.layoutMargins).height
        var rowCount = Double(viewModel.driversStates.count)
        if rowCount == 0 {
            rowCount = 22.0
        }
        let cellHeight = height / rowCount
        
        let s = TelemetryTableLayoutMetrics.scale(forRowHeight: cellHeight)
        let width = widthForColumn(indexPath.item, scale: s)

        return CGSize(width: width, height: cellHeight)
    }

    private func widthForColumn(_ rawIndex: Int, scale: Double) -> Double {
        guard let col = Column(rawValue: rawIndex) else {
            logger.warning("Unknown telemetry column index: \(rawIndex)")
            return 1
        }
        let base = TelemetryTableLayoutMetrics.baseColumnWidths
        switch col {
        case .identity:
            return base[0] * scale
        case .inPit:
            return base[1] * scale
        case .tire:
            return base[2] * scale
        case .intervalAhead:
            return base[3] * scale
        case .internalToFastest:
            return base[4] * scale
        }
    }
    
    // No upper bounds: we want the table width to grow to fit its content.
}
