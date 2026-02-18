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
    private let inPitCellFont = UIFont.boldSystemFont(ofSize: 15)
    private let driverCellHorizontalPadding: CGFloat = 20
    private let inPitCellHorizontalPadding: CGFloat = 16
    
    private enum Column: Int {
        case position = 0
        case driverCode = 1
        case inPit = 2
    }
    
    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableHeight = collectionView.bounds.inset(by: collectionView.layoutMargins).height
        var rowCount = Double(viewModel.driversStates.count)
        if rowCount == 0 {
            rowCount = 22.0
        }
        let cellHeight = availableHeight / rowCount

        let width: CGFloat
        switch Column(rawValue: indexPath.item) {
        case .position:
            width = widthForPositionColumn()
        case .driverCode:
            width = widthForDriverCodeColumn()
        case .inPit:
            width = widthForInPitColumn()
        case .none:
            logger.warning("Unknown telemetry column index: \(indexPath.item)")
            width = 1
        }
        
        return CGSize(width: width, height: cellHeight)
    }
    
    private func widthForPositionColumn() -> CGFloat {
        let maxPosition = max(22, viewModel.driversStates.count)
        let textWidth = textWidth(for: "\(maxPosition)", font: driverCellFont)
        return bounded(textWidth + driverCellHorizontalPadding, min: 40, max: 70)
    }
    
    private func widthForDriverCodeColumn() -> CGFloat {
        let driverCodeWidths = viewModel.driversStates.keys.map { driver in
            textWidth(for: viewModel.getDriverName(driver), font: driverCellFont)
        }
        let longestCodeWidth = driverCodeWidths.max() ?? textWidth(for: "HAM", font: driverCellFont)
        return bounded(longestCodeWidth + driverCellHorizontalPadding, min: 60, max: 110)
    }
    
    private func widthForInPitColumn() -> CGFloat {
        let text = "IN PIT"
        let textWidth = textWidth(for: text, font: inPitCellFont)
        return bounded(textWidth + inPitCellHorizontalPadding, min: 75, max: 120)
    }
    
    private func textWidth(for text: String, font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return ceil((text as NSString).size(withAttributes: attributes).width)
    }
    
    private func bounded(_ value: CGFloat, min minValue: CGFloat, max maxValue: CGFloat) -> CGFloat {
        min(max(value, minValue), maxValue)
    }
}
