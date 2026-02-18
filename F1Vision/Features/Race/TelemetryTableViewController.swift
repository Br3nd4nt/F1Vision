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
    private var lastCollectionViewSize: CGSize = .zero

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
        dataSource = TelemetryTableCollectionViewDataSource(viewModel: viewModel)
        delegate = TelemetryTableCollectionViewDelegate(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.$driversStates
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recalculateLayoutIfNeeded()
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
        collectionView.register(InPitCell.self, forCellWithReuseIdentifier: InPitCell.reuseId)
        collectionView.register(IntervalTimeCell.self, forCellWithReuseIdentifier: IntervalTimeCell.reuseId)
        collectionView.register(TireCell.self, forCellWithReuseIdentifier: TireCell.reuseId)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: viewModel.emptyCellReuseId)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.appBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    // MARK: public methods
    func configureView() {
        recalculateLayoutIfNeeded(force: true)
    }
    
    private func recalculateLayoutIfNeeded(force: Bool = false) {
        let size = collectionView.bounds.size
        guard force || size != lastCollectionViewSize else {
            return
        }
        lastCollectionViewSize = size
        
        // Re-run UICollectionViewDelegateFlowLayout sizing for current bounds.
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.performBatchUpdates(nil)
    }
}
