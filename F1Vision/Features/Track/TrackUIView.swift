//
//  TrackUIView.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Combine
import UIKit

final class TrackUIView: UIView {
    // MARK: - Track Layers
    private let trackShapeLayer = CAShapeLayer()
    private let trackBezierPath = UIBezierPath()
    private let trackStartPointLayer = CAShapeLayer()
    private let trackStartPointRadius: CGFloat = 4
    
    // MARK: - Driver Layers
    private var driverLayers: [Int: CAShapeLayer] = [:]
    private var driverTargets: [Int: CGPoint] = [:]
    private let driverAnimationDuration: CFTimeInterval = 0.35
    
    // MARK: - Debug Layers
    private let debugBoundingBoxLayer = CAShapeLayer()
    private let debugBoundingBoxCenterPointLayer = CAShapeLayer()
    
    // MARK: - MVVM
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
        layer.addSublayer(trackShapeLayer)
        trackShapeLayer.strokeColor = UIColor.lightGray.cgColor
        trackShapeLayer.fillColor = UIColor.clear.cgColor
        trackShapeLayer.lineWidth = 5
        
        layer.addSublayer(trackStartPointLayer)
        trackStartPointLayer.fillColor = UIColor.systemRed.cgColor
        trackStartPointLayer.strokeColor = UIColor.clear.cgColor
        
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
    
    // MARK: - Drawing
    
    private func drawTrack(with points: [CGPoint]) {
        guard !points.isEmpty else {
            trackStartPointLayer.path = nil
            trackShapeLayer.path = nil
            debugBoundingBoxLayer.path = nil
            debugBoundingBoxCenterPointLayer.path = nil
            return
        }
        
        trackBezierPath.removeAllPoints()
        trackBezierPath.move(to: points[0])
        
        for point in points.dropFirst() {
            trackBezierPath.addLine(to: point)
        }
        
        trackShapeLayer.path = trackBezierPath.cgPath
        trackStartPointLayer.path = UIBezierPath(
            arcCenter: points[0],
            radius: trackStartPointRadius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        ).cgPath
        
        updateDebugLayers(with: points)
    }
    
    private func drawDrivers(_ drivers: [Int: CGPoint]) {
        let currentDrivers = Set(driverLayers.keys)
        let newDrivers = Set(drivers.keys)
        let removed = currentDrivers.subtracting(newDrivers)
        for driver in removed {
            driverLayers[driver]?.removeFromSuperlayer()
            driverLayers.removeValue(forKey: driver)
            driverTargets.removeValue(forKey: driver)
        }

        for (driver, point) in drivers {
            if let last = driverTargets[driver], last == point {
                continue
            }
            driverTargets[driver] = point

            if let driverLayer = driverLayers[driver] {
                ensureDriverLayerConfigured(driverLayer)
                animateDriverLayer(driverLayer, to: point)
            } else {
                let driverLayer = CAShapeLayer()
                configureDriverLayer(driverLayer)
                driverLayer.position = point

                let color = viewModel.getDriverColor(driver)
                driverLayer.fillColor = color.cgColor
                layer.addSublayer(driverLayer)
                driverLayers[driver] = driverLayer
            }
        }
    }

    private func configureDriverLayer(_ layer: CAShapeLayer) {
        let size = viewModel.driverPointSize
        layer.bounds = CGRect(origin: .zero, size: size)
        layer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).cgPath
        layer.lineWidth = 2
        layer.actions = ["position": NSNull(), "path": NSNull(), "bounds": NSNull()]
    }

    private func ensureDriverLayerConfigured(_ layer: CAShapeLayer) {
        let size = viewModel.driverPointSize
        if layer.bounds.size != size {
            configureDriverLayer(layer)
        }
    }

    private func animateDriverLayer(_ layer: CAShapeLayer, to newCenter: CGPoint) {
        let startCenter = layer.presentation()?.position ?? layer.position
        guard startCenter != newCenter else {
            return
        }

        layer.removeAnimation(forKey: "driverPosition")

        let path = CGMutablePath()
        path.move(to: startCenter)
        path.addLine(to: newCenter)

        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path
        anim.duration = driverAnimationDuration
        anim.calculationMode = .cubic
        anim.timingFunctions = [CAMediaTimingFunction(name: .easeInEaseOut)]

        layer.add(anim, forKey: "driverPosition")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.position = newCenter
        CATransaction.commit()
    }
    
    private func updateDebugLayers(with points: [CGPoint]) {
        guard Configuration.debugMode else { return }
        let minX = points.map(\.x).min() ?? 0
        let maxX = points.map(\.x).max() ?? 0
        let minY = points.map(\.y).min() ?? 0
        let maxY = points.map(\.y).max() ?? 0
        
        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        debugBoundingBoxLayer.path = UIBezierPath(rect: rect).cgPath
        
        let center = CGPoint(x: (maxX + minX) / 2, y: (maxY + minY) / 2)
        debugBoundingBoxCenterPointLayer.path = UIBezierPath(
            arcCenter: center,
            radius: Configuration.driverPointRadius / 2,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        ).cgPath
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackShapeLayer.frame = bounds
        
        if !bounds.isEmpty {
            viewModel.sendViewSize(bounds.size)
        }
    }
    
    // MARK: - Public Methods
    
    func configureView() {
        viewModel.sendViewSize(bounds.size)
    }
}
