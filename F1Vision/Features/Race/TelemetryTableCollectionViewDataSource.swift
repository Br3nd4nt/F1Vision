//
//  TelemetryTableCollectionViewDataSource.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.12.2025.
//
import Puppy
import UIKit

final class TelemetryTableCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private let logger: Puppy = Dependencies.shared.logger
    private let viewModel: RaceViewModel
    private let columnCount = 5
    
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
        let rowCount = max(1.0, Double(viewModel.driversStates.count == 0 ? 22 : viewModel.driversStates.count))
        let height = Double(collectionView.bounds.inset(by: collectionView.layoutMargins).height)
        let metrics = TelemetryCellMetrics(rowHeight: height / rowCount)

        guard let driver = viewModel.driversStates.first(where: { $0.value.position == indexPath.section + 1 })?.key else {
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: viewModel.emptyCellReuseId,
                for: indexPath
            )
        }
        
        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DriverIdentityCell.reuseId,
                for: indexPath
            ) as? DriverIdentityCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: viewModel.emptyCellReuseId,
                    for: indexPath
                )
            }
            cell.configure(
                position: "\(indexPath.section + 1)",
                code: "\(viewModel.getDriverName(driver))",
                backgroundColor: viewModel.getDriverColor(driver),
                metrics: metrics
            )
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: InPitCell.reuseId,
                for: indexPath
            ) as? InPitCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: viewModel.emptyCellReuseId,
                    for: indexPath
                )
            }
            cell.configure(viewModel.driversStates[driver]?.inPit ?? true, metrics: metrics)
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TireCell.reuseId,
                for: indexPath
            ) as? TireCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: viewModel.emptyCellReuseId,
                    for: indexPath
                )
            }
            let stints = viewModel.driversStates[driver]?.stints ?? [.init()]
            cell.configure(stints.last ?? .init())
            return cell
        case 3:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IntervalTimeCell.reuseId,
                for: indexPath
            ) as? IntervalTimeCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: viewModel.emptyCellReuseId,
                    for: indexPath
                )
            }
            cell.configure(interval: viewModel.driversStates[driver]?.diffToAhead, metrics: metrics)
            return cell
        case 4:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: IntervalTimeCell.reuseId,
                for: indexPath
            ) as? IntervalTimeCell else {
                return collectionView.dequeueReusableCell(
                    withReuseIdentifier: viewModel.emptyCellReuseId,
                    for: indexPath
                )
            }
            cell.configure(interval: viewModel.driversStates[driver]?.diffToFastest, metrics: metrics)
            return cell
        default:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: viewModel.emptyCellReuseId,
                for: indexPath
            )
        }
    }
}
