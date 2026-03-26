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
    private var widthConstraint: NSLayoutConstraint?

    private let viewModel: RaceViewModel
    private let dataSource: UICollectionViewDataSource
    private let delegate: TelemetryTableCollectionViewDelegate
    
    private var lastCollectionViewSize: CGSize = .zero
    private var trailingConstraint: NSLayoutConstraint?

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
        dataSource = TelemetryTableCollectionViewDataSource(viewModel: viewModel)
        delegate = TelemetryTableCollectionViewDelegate(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.$driversStates
            .receive(on: DispatchQueue.main)
            .sink {[weak self] _ in
                guard let self else { return }
                self.collectionView.reloadData()
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

        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.sectionInset = .zero
        }

        collectionView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        collectionView.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor)
        collectionView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        // Do not pin both leading & trailing when using a fixed width constraint.
        // Keep it within the safe area without forcing it to stretch.
        let trailingConstraint = collectionView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor, 0, .lsOE)
        trailingConstraint.priority = .defaultLow
        self.trailingConstraint = trailingConstraint
        
        collectionView.contentInset = UIEdgeInsets(
            top: TelemetryTableLayoutMetrics.verticalPadding,
            left: TelemetryTableLayoutMetrics.horizontalPadding,
            bottom: TelemetryTableLayoutMetrics.verticalPadding,
            right: TelemetryTableLayoutMetrics.horizontalPadding
        )
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        collectionView.register(DriverCodeCell.self, forCellWithReuseIdentifier: DriverCodeCell.reuseId)
        collectionView.register(InPitCell.self, forCellWithReuseIdentifier: InPitCell.reuseId)
        collectionView.register(IntervalTimeCell.self, forCellWithReuseIdentifier: IntervalTimeCell.reuseId)
        collectionView.register(TireCell.self, forCellWithReuseIdentifier: TireCell.reuseId)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: viewModel.emptyCellReuseId)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: viewModel.emptyCellReuseId)
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.appBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        
        // Fix width to the sum of column widths (provided by the delegate), not to `layout.itemSize`.
        let widthConstraint = collectionView.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint.isActive = true
        self.widthConstraint = widthConstraint
        collectionView.setContentHuggingPriority(.required, for: .horizontal)
        collectionView.setContentCompressionResistancePriority(.required, for: .horizontal)

        applyFixedCollectionViewSize()
    }

    private func applyFixedCollectionViewSize() {
        let contentInsets = collectionView.contentInset.left + collectionView.contentInset.right
        widthConstraint?.constant = delegate.totalColumnsWidth() + contentInsets
    }
    
    // MARK: public methods
    func configureView() {
        applyFixedCollectionViewSize()
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
