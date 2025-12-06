//
//  TyreType.swift
//  F1Vision
//
//  Created by br3nd4nt on 06.12.2025.
//

import UIKit

enum TyreType: Int {
    case soft
    case medium
    case hard
    case intermediate
    case wet
    case undefined

    init(_ rawValue: Int) {
        switch rawValue {
        case 0:
            self = .soft
        case 1:
            self = .medium
        case 2:
            self = .hard
        case 3:
            self = .intermediate
        case 4:
            self = .wet
        default:
            self = .undefined
        }
    }

    var UIColor: UIColor {
        switch self {
        case .soft:
            return .systemRed
        case .medium:
            return .systemYellow
        case .hard:
            return .white
        case .intermediate:
            return .systemGreen
        case .wet:
            return .systemBlue
        default:
            return .systemGray
        }
    }

    var letter: String {
        switch self {
        case .soft:
            return "S"
        case .medium:
            return "M"
        case .hard:
            return "H"
        case .intermediate:
            return "I"
        case .wet:
            return "W"
        default:
            return "?"
        }
    }

    var fontColor: UIColor {
        switch self {
        case .soft:
            return .white
        case .medium:
            return .white
        case .intermediate:
            return .white
        case .wet:
            return .white
        case .hard:
            return .black
        default:
            return .black
        }
    }
}
