import Foundation

struct TelemetryCellMetrics: Sendable {
    let rowHeight: Double
    let referenceRowHeight: Double = Configuration.uiReferenceRowHeight

    var scale: Double {
        guard referenceRowHeight > 0 else { return 1 }
        let raw = rowHeight / referenceRowHeight
        return min(Configuration.uiMaxTextScale, max(Configuration.uiMinScale, raw))
    }
}
