//
//  TelemetryTableViewController.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import Combine
import Puppy
import SwiftUI
import UIKit

final class TelemetryTableViewController: UIViewController {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private var cancellables = Set<AnyCancellable>()

    private let viewModel: RaceViewModel
    private let dataSource: UICollectionViewDataSource
    private let delegate: TelemetryTableCollectionViewDelegate
    
    private let horizontalPadding: Double = 10
    private let verticalPadding: Double = 5

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
        dataSource = TelemetryTableCollectionViewDataSource(viewModel: viewModel)
        delegate = TelemetryTableCollectionViewDelegate(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.$driversTelemetry
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        self.viewModel.$driversOrder
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()

        if Configuration.debugMode {
            view.layer.borderColor = UIColor.yellow.cgColor
            view.layer.borderWidth = 1
        }
    }

    private func configureCollectionView() {
        view.configureSubview(collectionView)
        collectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        collectionView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor)
        collectionView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        collectionView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor)
        
        collectionView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: -verticalPadding,
            right: horizontalPadding
        )
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        collectionView.register(DriverCodeCell.self, forCellWithReuseIdentifier: DriverCodeCell.reuseId)
        collectionView.register(IntervalTimeCell.self, forCellWithReuseIdentifier: IntervalTimeCell.reuseId)
        collectionView.register(TyreCell.self, forCellWithReuseIdentifier: TyreCell.reuseId)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: viewModel.emptyCellReuseId)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.appBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
}
