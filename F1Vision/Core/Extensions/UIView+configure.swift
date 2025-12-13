//
//  UIView+configure.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

import UIKit

extension UIView {
    func configureSubview(_ subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
    }
}
