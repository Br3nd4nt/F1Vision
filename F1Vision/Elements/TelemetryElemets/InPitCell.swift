//
//  InPitCell.swift
//  F1Vision
//
//  Created by br3nd4nt on 18.02.2026.
//

import SwiftUI
import UIKit

final class InPitCell: UICollectionViewCell {
    private let borderLayer = CAShapeLayer()
    private let label = UILabel()

    private let cornerRadius: Double = 13
    private let fontSize: Double = 15

    private var value: Bool  = false
    
    var color: UIColor {
        if value {
            UIColor.accent
        } else {
            UIColor.secondaryLabel
        }
    }
    
    var strokeWidth: Double = 5
    
    static let reuseId = "InPitCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ value: Bool) {
        self.value = value
        borderLayer.strokeColor = color.cgColor
        label.textColor = color
    }

    private func configureUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = strokeWidth
        borderLayer.lineJoin = .round
        borderLayer.lineCap = .round
        
        contentView.layer.addSublayer(borderLayer)
        
        configureSubview(label)
        label.pinCenterX(to: self)
        label.pinCenterY(to: self)
        label.text = "IN PIT"
        label.font = .boldSystemFont(ofSize: fontSize)
        
        if Configuration.debugMode {
            layer.borderColor = UIColor.systemYellow.cgColor
            layer.borderWidth = 1
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let inset = strokeWidth
        let rect = contentView.bounds.insetBy(dx: inset, dy: inset)

        borderLayer.frame = contentView.bounds
        borderLayer.path = UIBezierPath(
            roundedRect: rect,
            cornerRadius: cornerRadius
        ).cgPath
    }
}

struct InPitCellPreviewWrapper: UIViewRepresentable {
    let value: Bool
    
    func makeUIView(context _: Context) -> InPitCell {
        let view = InPitCell()
        view.configure(value)
        return view
    }
    
    func updateUIView(_: InPitCell, context _: Context) {}
}

#Preview {
    VStack {
        ForEach(0 ..< 22) { i in
            InPitCellPreviewWrapper(value: i % 2 == 1)
//                .padding()
                .frame(width: 60, height: 44)
                .border(Color.black.opacity(0.3))
        }
    }
    .padding()
}
