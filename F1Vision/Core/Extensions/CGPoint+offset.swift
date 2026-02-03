//
//  CGPoint+offset.swift
//  F1Vision
//
//  Created by br3nd4nt on 03.02.2026.
//

import UIKit

extension CGPoint {
    func offset(with: CGSize) -> CGPoint {
        CGPoint(x: x - with.width / 2, y: y - with.height / 2)
    }
}
