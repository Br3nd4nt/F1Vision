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
        viewModel.numberOfTableColumns
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DriverCodeView

        let text: String
        let driver = viewModel.drivers[indexPath.section]

        switch indexPath.item {
        case 0:
            text = "\(driver.position)"
        case 1:
            text = driver.name
        default:
            text = "test"
        }

        cell.configure(code: text, backgroundColor: driver.color)

        return cell
    }
}
