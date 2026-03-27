//
//  TelemetryTableLayoutMetrics.swift
//  F1Vision
//
//  Created by br3nd4nt on 13.03.2026.
//

import UIKit

enum TelemetryTableLayoutMetrics {
    static let horizontalPadding: Double = 10
    static let verticalPadding: Double = 5
    
    // MARK: - Sizing (Height-driven / "Aspect Ratio")
    
    static let referenceRowHeight: Double = Configuration.uiReferenceRowHeight
    static let minScale: Double = Configuration.uiMinScale
    // Allow the table to keep growing with window height even if fonts are capped.
    static let maxScale: Double = 2.0
    
    // Column widths at `referenceRowHeight`.
    static let baseColumnWidths: [Double] = [
        120, // identity
        75,  // inPit
        80,  // tire
        75,  // intervalAhead
        75   // intervalToFastest
    ]

    static func clampRowHeight(_ rowHeight: Double) -> Double {
        let minH = referenceRowHeight * minScale
        let maxH = referenceRowHeight * Configuration.uiMaxTableScale
        return min(maxH, max(minH, rowHeight))
    }
    
    static func tableHeight(availableHeight: Double, rowCount: Int = 22) -> Double {
        let safeRowCount = max(1, rowCount)
        let rawRowHeight = availableHeight / Double(safeRowCount)
        let clamped = clampRowHeight(rawRowHeight)
        return clamped * Double(safeRowCount)
    }
    
    static func scale(forRowHeight rowHeight: Double) -> Double {
        guard referenceRowHeight > 0 else { return 1 }
        let raw = rowHeight / referenceRowHeight
        return min(maxScale, max(minScale, raw))
    }
    
    static func tableWidth(tableHeight: Double, rowCount: Int = 22) -> Double {
        let safeRowCount = max(1, rowCount)
        let rowHeight = clampRowHeight(tableHeight / Double(safeRowCount))
        let s = scale(forRowHeight: rowHeight)
        let columns = baseColumnWidths.reduce(0) { $0 + ($1 * s) }
        let contentInsets = horizontalPadding * 2
        return columns + contentInsets
    }
}
