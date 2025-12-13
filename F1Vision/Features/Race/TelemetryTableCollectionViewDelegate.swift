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

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableHeight = collectionView.bounds.inset(by: collectionView.layoutMargins).height
        let rowCount = 20.0
        let cellHeight = availableHeight / rowCount

        let width = viewModel.tableColumnWidths[indexPath.item]

        return CGSize(width: width, height: cellHeight)
    }
}
