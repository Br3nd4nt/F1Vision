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

    // track
    private let trackShapeLayer = CAShapeLayer()
    private let trackBezierPath = UIBezierPath()
    
    // drivers
    private var driverLayers: [Int: CAShapeLayer] = [:]

    private let debugBoundingBoxLayer = CAShapeLayer()
    private let debugBoundingBoxCenterPointLayer = CAShapeLayer()

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

        layer.addSublayer(trackShapeLayer)
        trackShapeLayer.strokeColor = UIColor.lightGray.cgColor
        trackShapeLayer.fillColor = UIColor.clear.cgColor
        trackShapeLayer.lineWidth = 5

        if Configuration.debugMode {
            debugBoundingBoxLayer.strokeColor = UIColor.red.cgColor
            debugBoundingBoxLayer.fillColor = UIColor.clear.cgColor
            debugBoundingBoxLayer.lineWidth = 1
            debugBoundingBoxLayer.lineDashPattern = [4, 3]
            layer.addSublayer(debugBoundingBoxLayer)
            
            debugBoundingBoxCenterPointLayer.fillColor = UIColor.red.cgColor
            layer.addSublayer(debugBoundingBoxCenterPointLayer)
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
            .sink { [weak self] drivers in
                self?.drawDrivers(drivers)
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

        trackBezierPath.removeAllPoints()
        trackBezierPath.move(to: points[0])

        for point in points.dropFirst() {
            trackBezierPath.addLine(to: point)
        }

        trackShapeLayer.path = trackBezierPath.cgPath
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
            let center = CGPoint(x: (maxX + minX) / 2, y: (maxY + minY) / 2)
            let centerPath = UIBezierPath(
                arcCenter: center,
                radius: Configuration.driverPointRadius / 2,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            debugBoundingBoxCenterPointLayer.path = centerPath.cgPath
        }
    }
    
    private func drawDrivers(_ drivers: [Int: CGPoint]) {
        clearDrivers()
        
        for (driver, point) in drivers {
            let offset = point.offset(with: viewModel.driverPointSize)
            let driverLayer = CAShapeLayer()
            driverLayer.path = UIBezierPath(
                ovalIn: CGRect(
                    origin: offset,
                    size: viewModel.driverPointSize
                )
            ).cgPath
            
            let color = Configuration.driverPointColor
            driverLayer.fillColor = color.cgColor
            driverLayer.lineWidth = 2
            
            layer.addSublayer(driverLayer)
            driverLayers[driver] = driverLayer
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        trackShapeLayer.frame = bounds

        if !bounds.isEmpty {
            viewModel.sendViewSize(bounds.size)
        }
    }
    
    private func clearDrivers() {
        for (_, layer) in driverLayers {
            layer.removeFromSuperlayer()
        }
        
        driverLayers.removeAll()
    }
}
