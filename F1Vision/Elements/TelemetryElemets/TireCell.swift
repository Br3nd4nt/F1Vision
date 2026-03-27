//
//  TireCell.swift
//  F1Vision
//
//  Created by br3nd4nt on 06.12.2025.
//

import SwiftUI
import UIKit

final class TireCell: UICollectionViewCell {
    private let circleBaсkgroundView = UIView()
    private let letterLabel = UILabel()
    private let lapsLabel = UILabel()
    private let pitsLabel = UILabel()
    private let textWrapper = UIView()

    private let circleScale: Double = 0.85
    private let letterFontScale: Double = 0.42
    private let lapsFontScale: Double = 0.42
    private let pitsFontScale: Double = 0.4

    private var circleWidthConstraint: NSLayoutConstraint?
    private var circleHeightConstraint: NSLayoutConstraint?
    
    static let reuseId = "TireCell"
    
    private var value: TireStint = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ newValue: TireStint) {
        value = newValue
        update()
    }
    
    private func update() {
        circleBaсkgroundView.backgroundColor = value.color
        circleBaсkgroundView.layer.borderColor = value.color.getDark(0.85).cgColor
        
        letterLabel.text = "\(value.letter)"
        if value.color.isLight {
            letterLabel.textColor = .black
        } else {
            letterLabel.textColor = .white
        }
        
        lapsLabel.text = "LAP \(value.totalLaps)"
        pitsLabel.text = "PIT \(value.stintNumber)"
        lapsLabel.textColor = .appText
        pitsLabel.textColor = .appText
    }

    private func configureUI() {
        configureSubview(circleBaсkgroundView)
        circleWidthConstraint = circleBaсkgroundView.setWidth(0) // updated in `layoutSubviews`
        circleHeightConstraint = circleBaсkgroundView.setHeight(0) // updated in `layoutSubviews`
        circleBaсkgroundView.layer.masksToBounds = true
        circleBaсkgroundView.pinLeft(to: self)
        circleBaсkgroundView.pinCenterY(to: self)

        configureSubview(letterLabel)
        letterLabel.textAlignment = .center

        letterLabel.pinAll(to: circleBaсkgroundView)
        
        textWrapper.configureSubview(lapsLabel)
        lapsLabel.pinLeft(to: textWrapper)
        lapsLabel.pinTop(to: textWrapper)
        lapsLabel.pinRight(to: textWrapper)
        textWrapper.configureSubview(pitsLabel)
        pitsLabel.pinLeft(to: textWrapper)
        pitsLabel.pinTop(to: lapsLabel.bottomAnchor)
        pitsLabel.pinRight(to: textWrapper)
        configureSubview(textWrapper)
        textWrapper.pinLeft(to: circleBaсkgroundView.trailingAnchor, 5)
        textWrapper.pinTop(to: self)
        textWrapper.pinBottom(to: self)
        
        if Configuration.debugMode {
            layer.borderColor = UIColor.yellow.cgColor
            layer.borderWidth = 1
            textWrapper.layer.borderColor = UIColor.magenta.cgColor
            textWrapper.layer.borderWidth = 1
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let side = bounds.height
        let circleSide = max(10, side * circleScale)
        circleWidthConstraint?.constant = circleSide
        circleHeightConstraint?.constant = circleSide
        circleBaсkgroundView.layer.cornerRadius = circleSide / 2
        circleBaсkgroundView.layer.borderWidth = circleSide * 0.15
        let scale = min(Configuration.uiMaxTextScale, max(Configuration.uiMinScale, Double(side) / Configuration.uiReferenceRowHeight))
        letterLabel.font = .systemFont(ofSize: max(10, circleSide * letterFontScale) * scale, weight: .bold)
        lapsLabel.font = .systemFont(ofSize: max(10, circleSide * lapsFontScale) * scale, weight: .bold)
        pitsLabel.font = .systemFont(ofSize: max(10, circleSide * pitsFontScale) * scale, weight: .light)
    }
}

// MARK: - Preview

#if DEBUG
private struct TireCellPreviewWrapper: UIViewRepresentable {
    let item: TireStint

    func makeUIView(context _: Context) -> TireCell {
        let cell = TireCell()
        cell.configure(item)
        return cell
    }

    func updateUIView(_ uiView: TireCell, context _: Context) {
        uiView.configure(item)
    }
}

#Preview("Tires (Telemetry Column)") {
    let items: [TireStint] = [
        .init(totalLaps: 0,  compound: "SOFT", newCompound: true, stintNumber: 0),
        .init(totalLaps: 1,  compound: "MEDIUM", newCompound: true, stintNumber: 1),
        .init(totalLaps: 12, compound: "HARD", newCompound: true, stintNumber: 2),
        .init(totalLaps: 20, compound: "INTERMEDIATE", newCompound: true, stintNumber: 3),
        .init(totalLaps: 11, compound: "WET", newCompound: true, stintNumber: 4),
        .init()
    ]
    
    VStack(spacing: 0) {
        ForEach(items) { item in
            TireCellPreviewWrapper(item: item)
                .frame(
                    width: TelemetryCellPreviewSupport.sizeForTelemetryColumn(0).width,
                    height: TelemetryCellPreviewSupport.sizeForTelemetryColumn(0).height
                )
        }
    }
}
#endif
