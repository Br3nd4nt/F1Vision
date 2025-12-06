//
//  TyreCell.swift
//  F1Vision
//
//  Created by br3nd4nt on 06.12.2025.
//

import UIKit
import SwiftUI

final class TyreCell: UICollectionViewCell {
    private let circleBaсkgroundView = UIView()
    private let letterLabel = UILabel()

    private let circleSize: Double = 30
    private let fontSize: Double = 15

    private var tyreType: TyreType = .undefined
    static let reuseId = "TyreCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ tyreType: TyreType) {
        self.tyreType = tyreType
        self.letterLabel.text = self.tyreType.letter
        self.letterLabel.textColor = self.tyreType.fontColor
        circleBaсkgroundView.backgroundColor = self.tyreType.UIColor
    }

    private func configureUI() {
        self.configureSubview(circleBaсkgroundView)
        circleBaсkgroundView.layer.cornerRadius = circleSize / 2
        circleBaсkgroundView.setWidth(circleSize)
        circleBaсkgroundView.setHeight(circleSize)
        circleBaсkgroundView.layer.masksToBounds = true
        circleBaсkgroundView.pinCenterX(to: self)
        circleBaсkgroundView.pinCenterY(to: self)

        self.configureSubview(letterLabel)
        letterLabel.font = .systemFont(ofSize: fontSize, weight: .bold)
        letterLabel.textAlignment = .center

        letterLabel.pinAll(to: circleBaсkgroundView)

        if Configuration.debugMode {
            self.layer.borderColor = UIColor.yellow.cgColor
            self.layer.borderWidth = 1
        }
    }
}

// MARK: - Preview
#if DEBUG

struct TyreCellPreviewWrapper: UIViewRepresentable {
    let tyreType: Int

    func makeUIView(context: Context) -> TyreCell {
        let view = TyreCell()
        view.configure(TyreType(tyreType))
        return view
    }

    func updateUIView(_ uiView: TyreCell, context: Context) {}
}

#Preview {
    HStack {
        ForEach(0..<6) { i in
            TyreCellPreviewWrapper(tyreType: i)
                .padding()
        }
    }
    .padding()
}
#endif
