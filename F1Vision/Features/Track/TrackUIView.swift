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

    // Driver position layers
    private var driverLayers: [String: CAShapeLayer] = [:]
    private var driverLabelLayers: [String: CATextLayer] = [:]

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
        viewModel.$driverPoints
            .receive(on: DispatchQueue.main)
            .sink { [weak self] positions in
                self?.updateDriverPositions(positions)
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

    // MARK: - Driver Position Drawing

    private func updateDriverPositions(_ driverPositions: [TrackDriverPosition]) {
        clearDriverLayers()

        for driverPosition in driverPositions {
            addDriverLayer(driverPosition)
        }
    }

    private func addDriverLayer(_ driverPosition: TrackDriverPosition) {
        let driverId = driverPosition.name
//
//        // Create driver marker (circle)
        let driverLayer = CAShapeLayer()
        driverLayer.path = UIBezierPath(
            ovalIn: CGRect(
                origin: driverPosition.point,
                size: viewModel.driverPointSize
            )
        ).cgPath
        let color = driverPosition.color
//        // Use team color or fallback to white
//        let teamColor: UIColor
//        if driverPosition.teamColor.hasPrefix("#") {
//            teamColor = UIColor(hex: driverPosition.teamColor)
//        } else {
//            teamColor = UIColor.white
//        }
//
        driverLayer.fillColor = color.cgColor
//        driverLayer.strokeColor = UIColor.black.cgColor
        driverLayer.lineWidth = 2
//
//        // Create driver code label
//        let labelLayer = CATextLayer()
//        labelLayer.string = driverPosition.driverCode
//        labelLayer.fontSize = 12
//        labelLayer.font = UIFont.boldSystemFont(ofSize: 12)
//        labelLayer.foregroundColor = UIColor.black.cgColor
//        labelLayer.alignmentMode = .center
//        labelLayer.frame = CGRect(
//        x: driverPosition.translatedPosition.x,
//        y: driverPosition.translatedPosition.y,
//        width: 30,
//        height: 20
//        )
//        labelLayer.backgroundColor = UIColor.white.withAlphaComponent(0.8).cgColor
//        labelLayer.cornerRadius = 4
//
//        // Add to view
        layer.addSublayer(driverLayer)
//        layer.addSublayer(labelLayer)
//
//        // Store references
        driverLayers[driverId] = driverLayer
//        driverLabelLayers[driverId] = labelLayer
    }

    private func clearDriverLayers() {
        for layer in driverLayers.values {
            layer.removeFromSuperlayer()
        }
//        for layer in driverLabelLayers.values {
//            layer.removeFromSuperlayer()
//        }
        driverLayers.removeAll()
//        driverLabelLayers.removeAll()
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
