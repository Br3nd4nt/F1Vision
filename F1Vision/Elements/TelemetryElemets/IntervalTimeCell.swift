//
//  IntervalTimeCell.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.12.2025.
//

import SwiftUI
import UIKit

final class IntervalTimeCell: UICollectionViewCell {
    private let codeLabel = UILabel()

    private let verticalPadding: Double = 0
    private let horizontalPadding: Double = 10
    private let fontSize: Double = 15
    private let referenceRowHeight: Double = 32

    static let reuseId = "IntervalTimeCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(interval: String?, metrics: TelemetryCellMetrics? = nil) {
        // Font scaling happens in `layoutSubviews` so it updates on window/row size changes.
        guard let interval, !interval.isEmpty else {
            codeLabel.text = "-"
            return
        }
        codeLabel.text = interval
    }

    private func configureUI() {
        // label
        self.configureSubview(codeLabel)
        codeLabel.pinLeft(to: self, horizontalPadding)
        codeLabel.pinRight(to: self, horizontalPadding)
        codeLabel.pinTop(to: self, verticalPadding)
        codeLabel.pinBottom(to: self, verticalPadding)

        codeLabel.font = .systemFont(ofSize: fontSize, weight: .bold)
        codeLabel.textAlignment = .center

        if Configuration.debugMode {
            layer.borderColor = UIColor.yellow.cgColor
            layer.borderWidth = 1
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let rowHeight = Double(bounds.height)
        let scale = min(1.35, max(0.75, rowHeight / referenceRowHeight))
        codeLabel.font = .systemFont(ofSize: fontSize * scale, weight: .bold)
    }
}

// MARK: - Preview

#Preview("+0.756 (Telemetry Size)") {
    let cell = IntervalTimeCell()
    cell.configure(interval: "+0.756")
    return UIKitViewPreview(view: cell)
        .frame(
            width: TelemetryCellPreviewSupport.sizeForTelemetryColumn(2).width,
            height: TelemetryCellPreviewSupport.sizeForTelemetryColumn(2).height
        )
}

#Preview("- (Telemetry Size)") {
    let cell = IntervalTimeCell()
    cell.configure(interval: nil)
    return UIKitViewPreview(view: cell)
        .frame(
            width: TelemetryCellPreviewSupport.sizeForTelemetryColumn(2).width,
            height: TelemetryCellPreviewSupport.sizeForTelemetryColumn(2).height
        )
}
