//
//  TrackUIView.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Combine
import Puppy
import UIKit

final class TrackUIView: UIView {
    private let logger: Puppy = Dependencies.shared.logger

    // MARK: - Properties

    private let shapeLayer = CAShapeLayer()
    private let bezierPath = UIBezierPath()

    private let debugBoundingBoxLayer = CAShapeLayer()

    private let viewModel: TrackViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(_ viewModel: TrackViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupUI()
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .background

        layer.addSublayer(shapeLayer)
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5

        if Configuration.debugMode {
            debugBoundingBoxLayer.strokeColor = UIColor.red.cgColor
            debugBoundingBoxLayer.fillColor = UIColor.clear.cgColor
            debugBoundingBoxLayer.lineWidth = 1
            debugBoundingBoxLayer.lineDashPattern = [4, 3]
            layer.addSublayer(debugBoundingBoxLayer)
        }
    }

    private func setupBindings() {
        viewModel.$trackPoints
            .receive(on: DispatchQueue.main)
            .sink { [weak self] points in
                self?.drawTrack(with: points)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    func configureView() {
        viewModel.sendViewSize(bounds.size)
    }

    // MARK: - Drawing

    private func drawTrack(with points: [CGPoint]) {
        guard !points.isEmpty else {
            return
        }

        bezierPath.removeAllPoints()
        bezierPath.move(to: points[0])

        for point in points.dropFirst() {
            bezierPath.addLine(to: point)
        }

        shapeLayer.path = bezierPath.cgPath
        if Configuration.debugMode {
            let minX = points.map(\.x).min() ?? 0
            let maxX = points.map(\.x).max() ?? 0
            let minY = points.map(\.y).min() ?? 0
            let maxY = points.map(\.y).max() ?? 0
            let rect = CGRect(
                x: minX,
                y: minY,
                width: maxX - minX,
                height: maxY - minY
            )
            let bboxPath = UIBezierPath(rect: rect)
            debugBoundingBoxLayer.path = bboxPath.cgPath
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds

        if !bounds.isEmpty {
            viewModel.sendViewSize(bounds.size)
        }
    }
}
