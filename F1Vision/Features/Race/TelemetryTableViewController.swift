//
//  RaceTableView.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import UIKit
import Combine
import SwiftUI
import Puppy

final class TelemetryTableViewController: UIViewController {
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: TelemetryCollectionViewFlowLayout())

    private var cancellables = Set<AnyCancellable>()

    private let viewModel: RaceViewModel
    private let dataSource: UICollectionViewDataSource

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
        self.dataSource = TelemetryTableCollectionViewDataSource(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.$drivers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }

    private func configureCollectionView() {
        collectionView.backgroundColor = .systemGroupedBackground

        collectionView.dataSource = self.dataSource
        collectionView.register(DriverCodeView.self, forCellWithReuseIdentifier: "cell")

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false

        collectionView.backgroundColor = UIColor(hex: "#EEEEEE")

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
