//
//  TelemetryTableCollectionViewDataSource.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.12.2025.
//

import UIKit

final class TelemetryTableCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private let viewModel: RaceViewModel
    
    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.driversOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.tableColumnWidths.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let driver = viewModel.driversOrder.first(where: { $0.value == indexPath.section + 1 })?.key else {
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
                    code: "\(driver)",
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
        default:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: viewModel.emptyCellReuseId,
                for: indexPath
            )
        }
    }
}
