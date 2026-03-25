//
//  DriverIdentityCell.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.03.2026.
//

import SwiftUI
import UIKit

final class DriverIdentityCell: UICollectionViewCell {
    private let backgroundWrapperView = UIView()
    private let stackView = UIStackView()
    private let positionLabel = UILabel()
    private let codeLabel = UILabel()

    private let cornerRadius: Double = 12
    private let verticalPadding: Double = 5
    private let horizontalPadding: Double = 5
    private let fontSize: Double = 20

    static let reuseId = "DriverIdentityCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(position: String, code: String, backgroundColor: UIColor) {
        backgroundWrapperView.backgroundColor = backgroundColor
        positionLabel.text = position
        codeLabel.text = code

        let textColor: UIColor = backgroundColor.isLight ? .dark : .light
        positionLabel.textColor = textColor
        codeLabel.textColor = textColor
    }

    private func configureUI() {
        // background
        configureSubview(backgroundWrapperView)
        backgroundWrapperView.layer.cornerRadius = cornerRadius
        backgroundWrapperView.isUserInteractionEnabled = false

        // stack
        configureSubview(stackView)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.isUserInteractionEnabled = false

        // labels
        positionLabel.font = .systemFont(ofSize: fontSize, weight: .bold)
        positionLabel.textAlignment = .center
        codeLabel.font = .systemFont(ofSize: fontSize, weight: .bold)
        codeLabel.textAlignment = .center

        stackView.addArrangedSubview(positionLabel)
        stackView.addArrangedSubview(codeLabel)

        // layout: fixed pill and equally-sized halves inside
        backgroundWrapperView.pinLeft(to: self, horizontalPadding)
        backgroundWrapperView.pinRight(to: self, horizontalPadding)
        backgroundWrapperView.pinTop(to: self, verticalPadding)
        backgroundWrapperView.pinBottom(to: self, verticalPadding)

        stackView.pinLeft(to: backgroundWrapperView, 0)
        stackView.pinRight(to: backgroundWrapperView, 0)
        stackView.pinTop(to: backgroundWrapperView, 0)
        stackView.pinBottom(to: backgroundWrapperView, 0)

        if Configuration.debugMode {
            layer.borderColor = UIColor.systemPink.cgColor
            layer.borderWidth = 1
        }
    }
}

// MARK: - Preview

#Preview("Dark") {
    let v = DriverIdentityCell()
    v.configure(position: "11", code: "HAM", backgroundColor: UIColor(hex: "#E80020"))
    return v
}

#Preview("Light") {
    let v = DriverIdentityCell()
    v.configure(position: "1", code: "BEA", backgroundColor: UIColor(hex: "#B6BABD"))
    return v
}

