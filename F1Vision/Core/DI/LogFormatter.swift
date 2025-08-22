//
//  LogFormatter.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Puppy
import Foundation

// swiftlint:disable all
struct LogFormatter: LogFormattable {
    private let dateFormat = DateFormatter()

    init() {
        dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    }
    func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) -> String {
        let date = dateFormatter(date, withFormatter: dateFormat)
        let fileName = fileName(file)
        var q: String = function
        if let parentheses = function.firstIndex(of: "(") {
            q = String(function[..<parentheses])
        } else {
        }
        return "\(date) [\(level.emoji) \(level)]\t\(message) (\(fileName.replacingOccurrences(of: ".swift", with: "")):\(q):\(line))"
    }
}
// swiftlint:enable all
