//
//  TelemetryCollectionViewFlowLayout.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.12.2025.
//

import UIKit

final class TelemetryCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let cv = collectionView else {
            return
        }
        let availableHeight = cv.bounds.inset(by: cv.layoutMargins).height
        let rowCount = 20.0
        let cellHeight = (availableHeight / rowCount).rounded(.down)
        self.itemSize = CGSize(width: itemSize.width, height: cellHeight)
        self.minimumInteritemSpacing = 1
        self.sectionInset = UIEdgeInsets(
            top: 1,
            left: 0.0,
            bottom: 0.0,
            right: 0.0
        )
        self.sectionInsetReference = .fromSafeArea
    }
}
