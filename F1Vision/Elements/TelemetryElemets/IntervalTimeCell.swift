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
    private let fontSize: Double = 20

    static let reuseId = "IntervalTimeCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(interval: Double?) {
        guard let interval else {
            codeLabel.text = "-"
            return
        }
        codeLabel.text = String(format: "%.3f", interval)
    }

    private func configureUI() {
        // label
//        self.configureSubview(codeLabel)
        addSubview(codeLabel)
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
}

// MARK: - Preview

#Preview {
    let v = IntervalTimeCell()
    v.configure(interval: 0.7561234134)
    return v
}
