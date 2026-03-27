//
//  UIColor+getDark.swift
//  F1Vision
//
//  Created by br3nd4nt on 27.03.2026.
//

import UIKit

extension UIColor {
    func getDark(_ mult: CGFloat = 0.9) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return UIColor(hue: hue, saturation: saturation, brightness: mult * brightness, alpha: alpha)
    }
}
