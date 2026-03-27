//
//  UIColor+isLight.swift
//  F1Vision
//
//  Created by br3nd4nt on 27.03.2026.
//

import UIKit

extension UIColor {
    var isLight: Bool {
        var white: CGFloat = 0
        self.getWhite(&white, alpha: nil)
        return white > 0.7
    }
}
