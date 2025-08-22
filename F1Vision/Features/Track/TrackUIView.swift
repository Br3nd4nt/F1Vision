//
//  TrackUIView.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import UIKit
import Puppy
import Combine
import SwiftUI

final class TrackUIView: UIView {
    private let logger: Puppy = Dependencies.shared.logger

    private let shapeLayer = CAShapeLayer()
    private let bezierPath = UIBezierPath()

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
    }

    // MARK: - Public Methods

    func configureView() {
        guard viewModel.trackData != nil else {
            logger.warning("track data is nil")
            return
        }

        viewModel.translatePoints(for: bounds.size)

        if Configuration.isHitBoxesEnabled {
            drawHitbox()
        }
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

        if Configuration.isHitBoxesEnabled {
            updateHitbox()
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        shapeLayer.frame = bounds

        if !bounds.isEmpty && viewModel.trackData != nil {
            viewModel.translatePoints(for: bounds.size)
        }
    }

    // MARK: - Hitbox Drawing (for debugging)

    private var lastHitboxBounds: CGRect = .zero

    private func updateHitbox() {
        guard Configuration.isHitBoxesEnabled,
              let hitboxBounds = viewModel.getTranslatedBounds() else { return }

        guard hitboxBounds != lastHitboxBounds else {
            return
        }

        lastHitboxBounds = hitboxBounds
        drawHitbox()
    }

    private func drawHitbox() {
        guard Configuration.isHitBoxesEnabled,
              let hitboxBounds = viewModel.getTranslatedBounds() else { return }

        layer.sublayers?.removeAll { $0 is CAShapeLayer && $0 != shapeLayer }

        let hitboxLayer = CAShapeLayer()
        hitboxLayer.path = UIBezierPath(rect: hitboxBounds).cgPath
        hitboxLayer.fillColor = UIColor.clear.cgColor
        hitboxLayer.strokeColor = UIColor.systemPink.cgColor
        hitboxLayer.lineWidth = 2

        layer.addSublayer(hitboxLayer)
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
    }
}

struct TrackUIView_Previews: PreviewProvider {
    static var previews: some View {
        TrackUIViewRepresentable(viewModel: TrackViewModel())
//            .frame(width: 300, height: 200)
            .background(Color.black)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Track UI View")
    }
}
#endif
