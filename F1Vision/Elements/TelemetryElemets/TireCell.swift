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

    private let circleSize: Double = 30
    private let fontSize: Double = 15

//    private var tyreType: TireType = .undefined
    static let reuseId = "TireCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    func configure(_ tireType: TireType) {
//        self.tireType = tireType
//        letterLabel.text = self.tyreType.letter
//        letterLabel.textColor = self.tyreType.fontColor
//        circleBaсkgroundView.backgroundColor = self.tyreType.UIColor
//    }

    private func configureUI() {
        configureSubview(circleBaсkgroundView)
        circleBaсkgroundView.layer.cornerRadius = circleSize / 2
        circleBaсkgroundView.setWidth(circleSize)
        circleBaсkgroundView.setHeight(circleSize)
        circleBaсkgroundView.layer.masksToBounds = true
        circleBaсkgroundView.pinCenterX(to: self)
        circleBaсkgroundView.pinCenterY(to: self)

        configureSubview(letterLabel)
        letterLabel.font = .systemFont(ofSize: fontSize, weight: .bold)
        letterLabel.textAlignment = .center

        letterLabel.pinAll(to: circleBaсkgroundView)

        if Configuration.debugMode {
            layer.borderColor = UIColor.yellow.cgColor
            layer.borderWidth = 1
        }
    }
}

// MARK: - Preview

#if DEBUG

    struct TyreCellPreviewWrapper: UIViewRepresentable {
        let tyreType: Int

        func makeUIView(context _: Context) -> TireCell {
            let view = TireCell()
//            view.configure(TyreType(tyreType))
            return view
        }

        func updateUIView(_: TireCell, context _: Context) {}
    }

    #Preview {
        HStack {
            ForEach(0 ..< 6) { i in
                TyreCellPreviewWrapper(tyreType: i)
                    .padding()
            }
        }
        .padding()
    }
#endif
