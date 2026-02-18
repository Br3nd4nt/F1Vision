//
//  TelemetryTableCollectionViewDataSource.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.12.2025.
//

import UIKit

final class TelemetryTableCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private let viewModel: RaceViewModel
    private let columnCount = 3
    
    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.driversStates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        columnCount
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let driver = viewModel.driversStates.first(where: { $0.value.position == indexPath.section + 1 })?.key else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: viewModel.emptyCellReuseId,
                for: indexPath
            )
        }
        
        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DriverCodeCell.reuseId,
                for: indexPath
            ) as? DriverCodeCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: viewModel.emptyCellReuseId,
                    for: indexPath
                )
            }
            cell.configure(
                    code: "\(indexPath.section + 1)",
                    backgroundColor: viewModel.getDriverColor(driver)
                )
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DriverCodeCell.reuseId,
                for: indexPath
            ) as? DriverCodeCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: viewModel.emptyCellReuseId,
                    for: indexPath
                )
            }
            cell.configure(
                    code: "\(viewModel.getDriverName(driver))",
                    backgroundColor: viewModel.getDriverColor(driver)
                )
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InPitCell.reuseId,
                for: indexPath
            ) as? InPitCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: viewModel.emptyCellReuseId,
                    for: indexPath
                )
            }
            cell.configure(viewModel.driversStates[driver]?.inPit ?? true)
            return cell
        default:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: viewModel.emptyCellReuseId,
                for: indexPath
            )
        }
    }
}
