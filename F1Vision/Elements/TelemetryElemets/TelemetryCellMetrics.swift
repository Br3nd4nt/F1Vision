import Foundation

struct TelemetryCellMetrics: Sendable {
    let rowHeight: Double
    let referenceRowHeight: Double = 32

    var scale: Double {
        guard referenceRowHeight > 0 else { return 1 }
        let raw = rowHeight / referenceRowHeight
        return min(1.35, max(0.75, raw))
    }
}

