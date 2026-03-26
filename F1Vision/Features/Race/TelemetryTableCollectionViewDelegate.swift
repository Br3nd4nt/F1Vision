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
    private let driverCellFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    private let intervalCellFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    private let inPitCellFont = UIFont.boldSystemFont(ofSize: 15)
    private let driverCellHorizontalPadding: Double = 20
    private let intervalCellHorizontalPadding: Double = 12
    private let inPitCellHorizontalPadding: Double = 16
    
    private enum Column: Int {
        case position = 0
        case driverCode = 1
        case inPit = 2
        case intervalAhead = 3
        case internalToFastest = 4
    }
    
    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }

    func totalColumnsWidth() -> Double {
        widthForPositionColumn()
            + widthForDriverCodeColumn()
            + widthForInPitColumn()
            + widthForIntervalColumn()
            + widthForIntervalColumn()
    }

    var columnCount: Int { 5 }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width: Double
        switch Column(rawValue: indexPath.item) {
        case .position:
            width = widthForPositionColumn()
        case .driverCode:
            width = widthForDriverCodeColumn()
        case .inPit:
            width = widthForInPitColumn()
        case .intervalAhead, .internalToFastest:
            width = widthForIntervalColumn()
        case .none:
            logger.warning("Unknown telemetry column index: \(indexPath.item)")
            width = 1
        }
        
        // Height is managed by the collection view's constraints (it can resize with the window).
        // Each cell should simply match the available row height as computed by the layout.
        let height = collectionView.bounds.inset(by: collectionView.layoutMargins).height
        var rowCount = Double(viewModel.driversStates.count)
        if rowCount == 0 {
            rowCount = 22.0
        }
        let cellHeight = height / rowCount

        return CGSize(width: width, height: cellHeight)
    }
    
    private func widthForPositionColumn() -> Double {
        let maxPosition = max(22, viewModel.driversStates.count)
        let textWidth = textWidth(for: "\(maxPosition)", font: driverCellFont)
        return max(textWidth + driverCellHorizontalPadding, 40)
    }
    
    private func widthForDriverCodeColumn() -> Double {
        let driverCodeWidths = viewModel.driversStates.keys.map { driver in
            textWidth(for: viewModel.getDriverName(driver), font: driverCellFont)
        }
        let longestCodeWidth = driverCodeWidths.max() ?? textWidth(for: "HAM", font: driverCellFont)
        return max(longestCodeWidth + driverCellHorizontalPadding, 60)
    }
    
    private func widthForInPitColumn() -> Double {
        let text = "IN PIT"
        let textWidth = textWidth(for: text, font: inPitCellFont)
        return max(textWidth + inPitCellHorizontalPadding, 75)
    }
    
    private func widthForIntervalColumn() -> Double {
        let intervalWidths = viewModel.driversStates.values.map { state in
            textWidth(for: formattedInterval(state.diffToAhead), font: intervalCellFont)
        }
        let longestIntervalWidth = intervalWidths.max() ?? textWidth(for: "-0.000", font: intervalCellFont)
        return max(longestIntervalWidth + intervalCellHorizontalPadding, 40)
    }
    
    private func formattedInterval(_ value: Double) -> String {
        String(format: "%.3f", value)
    }
    
    private func textWidth(for text: String, font: UIFont) -> Double {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return ceil((text as NSString).size(withAttributes: attributes).width)
    }
    
    // No upper bounds: we want the table width to grow to fit its content.
}
