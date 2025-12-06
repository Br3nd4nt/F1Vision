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
        viewModel.drivers.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.tableColumnWidths.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let driver = viewModel.drivers[indexPath.section]

        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DriverCodeCell.reuseId, for: indexPath) as? DriverCodeCell else {
                return UICollectionViewCell()
            }
            cell.configure(code: "\(driver.position)", backgroundColor: driver.color)
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DriverCodeCell.reuseId, for: indexPath) as? DriverCodeCell else {
                return UICollectionViewCell()
            }
            cell.configure(code: driver.name, backgroundColor: driver.color)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TyreCell.reuseId, for: indexPath) as? TyreCell else {
                return UICollectionViewCell()
            }
            cell.configure(TyreType(driver.tyre))
            return cell
//        case 3:
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntervalTimeCell.reuseId, for: indexPath) as? IntervalTimeCell else {
//                return UICollectionViewCell()
//            }
//            cell.configure(interval: driver.interval)
//            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
