//
//  DriverCodeCell.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.12.2025.
//

import SwiftUI
import UIKit

final class DriverCodeCell: UICollectionViewCell {
    private let backgroundWrapperView = UIView()
    private let codeLabel = UILabel()

    private let cornerRadius: Double = 12
    private let verticalPadding: Double = 5
    private let horizontalPadding: Double = 10
    private let fontSize: Double = 20

    static var reuseId = "DriverCodeCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(code: String, backgroundColor: UIColor) {
        backgroundWrapperView.backgroundColor = backgroundColor
        codeLabel.text = code
        if backgroundColor.isLight {
            codeLabel.textColor = .dark
        } else {
            codeLabel.textColor = .light
        }
    }

    private func configureUI() {
        // background
        configureSubview(backgroundWrapperView)
        backgroundWrapperView.layer.cornerRadius = cornerRadius

        // label
        configureSubview(codeLabel)
        codeLabel.pinCenterX(to: self)
        codeLabel.pinCenterY(to: self)

        codeLabel.font = .systemFont(ofSize: fontSize, weight: .bold)
        codeLabel.textAlignment = .center

        // wrapping background around text
        backgroundWrapperView.pinLeft(to: codeLabel, -horizontalPadding)
        backgroundWrapperView.pinRight(to: codeLabel, -horizontalPadding)
        backgroundWrapperView.pinTop(to: codeLabel, -verticalPadding)
        backgroundWrapperView.pinBottom(to: codeLabel, -verticalPadding)

        if Configuration.debugMode {
            layer.borderColor = UIColor.yellow.cgColor
            layer.borderWidth = 1
        }
    }
}

// MARK: - Preview

#Preview("Dark") {
    let v = DriverCodeCell()
    v.configure(code: "HAM", backgroundColor: UIColor(hex: "#E80020"))
    return v
}

#Preview("Light") {
    let v = DriverCodeCell()
    v.configure(code: "BEA", backgroundColor: UIColor(hex: "#B6BABD"))
    return v
}
