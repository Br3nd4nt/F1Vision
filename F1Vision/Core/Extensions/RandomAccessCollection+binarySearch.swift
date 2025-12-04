//
//  RandomAccessCollection+binarySearch.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

extension RandomAccessCollection where Element: Comparable {
    func binarySearch(for value: Element) -> Index {
        var low = startIndex
        var high = endIndex

        while low < high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if self[mid] < value {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
}
