//
//  TrackUIView.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import UIKit
import Combine

final class TrackUIView: UIView {
    // MARK: - Properties

    private let shapeLayer = CAShapeLayer()
    private let bezierPath = UIBezierPath()

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
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        layer.addSublayer(shapeLayer)
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5
    }

    private func setupBindings() {
        viewModel.$translatedPoints
            .receive(on: DispatchQueue.main)
            .sink { [weak self] points in
                self?.drawTrack(with: points)
            }
            .store(in: &cancellables)

        viewModel.$driverPositions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] driverPositions in
                self?.updateDriverPositions(driverPositions)
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    func configureView() {
        guard viewModel.trackData != nil else {
            return
        }
        viewModel.translatePoints(for: bounds.size)
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
    }

    // MARK: - Driver Position Drawing

    private func updateDriverPositions(_ driverPositions: [DriverPosition]) {
        clearDriverLayers()

        for driverPosition in driverPositions {
            addDriverLayer(for: driverPosition)
        }
    }

    private func addDriverLayer(for driverPosition: DriverPosition) {
        let driverId = driverPosition.driver.driverId.id

        // Create driver marker (circle)
        let driverLayer = CAShapeLayer()
        driverLayer.path = UIBezierPath(ovalIn: CGRect(x: -8, y: -8, width: 16, height: 16)).cgPath

        // Use team color or fallback to white
        let teamColor: UIColor
        if driverPosition.teamColor.hasPrefix("#") {
            teamColor = UIColor(hex: driverPosition.teamColor)
        } else {
            teamColor = UIColor.white
        }

        driverLayer.fillColor = teamColor.cgColor
        driverLayer.strokeColor = UIColor.black.cgColor
        driverLayer.lineWidth = 2
        driverLayer.position = driverPosition.translatedPosition

        // Create driver code label
        let labelLayer = CATextLayer()
        labelLayer.string = driverPosition.driverCode
        labelLayer.fontSize = 12
        labelLayer.font = UIFont.boldSystemFont(ofSize: 12)
        labelLayer.foregroundColor = UIColor.black.cgColor
        labelLayer.alignmentMode = .center
        labelLayer.frame = CGRect(x: -15, y: 12, width: 30, height: 20)
        labelLayer.backgroundColor = UIColor.white.withAlphaComponent(0.8).cgColor
        labelLayer.cornerRadius = 4

        // Add to view
        layer.addSublayer(driverLayer)
        layer.addSublayer(labelLayer)

        // Store references
        driverLayers[driverId] = driverLayer
        driverLabelLayers[driverId] = labelLayer
    }

    private func clearDriverLayers() {
        for layer in driverLayers.values {
            layer.removeFromSuperlayer()
        }
        for layer in driverLabelLayers.values {
            layer.removeFromSuperlayer()
        }
        driverLayers.removeAll()
        driverLabelLayers.removeAll()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds

        if !bounds.isEmpty && viewModel.trackData != nil {
            viewModel.translatePoints(for: bounds.size)
        }
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
import SwiftUI

struct TrackUIViewRepresentable: UIViewRepresentable {
    let viewModel: TrackViewModel

    func makeUIView(context: Context) -> TrackUIView {
        let view = TrackUIView(viewModel)
        view.configureView()
        return view
    }

    func updateUIView(_ uiView: TrackUIView, context: Context) {
        // No updates needed for this view
    }
}

struct TrackUIView_Previews: PreviewProvider {
    static var previews: some View {
        TrackUIViewRepresentable(viewModel: TrackViewModel())
            .background(Color.black)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Track UI View")
    }
}
#endif
