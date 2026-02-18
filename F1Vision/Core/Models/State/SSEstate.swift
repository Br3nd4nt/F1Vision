//
//  State.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.01.2026.
//

import Foundation
import Puppy

@MainActor
struct SSEstate: Codable {
    private static let jsonDecoder = Dependencies.shared.jsonDecoder
    private static let decodingService = Dependencies.shared.zlibDecoder
    private static let logger: Puppy = Dependencies.shared.logger

    var driversStates: [Int: DriverState]
    let sessionInfo: SessionInfo?
    let driversInfo: [Int: DriverFullInfo]?

    init(_ response: SSEmessage) throws {
        // session info
        Self.logger.debug(String(describing: response))
        guard let info = response.sessionInfo else {
            throw StateError.SessionInfoNotFound
        }
        sessionInfo = info

        // driver info
        guard let driverList = response.DriverList else {
            throw StateError.DriversInfoNotFound
        }
        var infoList = [Int: DriverFullInfo]()
        for (driver, info) in driverList {
            guard let number = Int(driver) else {
                continue  // ???
            }
            infoList[number] = info
        }
        driversInfo = infoList

        // timing data (drivers order)
        guard let timingData = response.timingData else {
            throw StateError.TimingDataNotFound
        }

        driversStates = [:]
        for (driver, data) in timingData.Lines {
            guard let number = Int(driver), let pos = Int(data.Position) else {
                throw StateError.TimingDataNotFound
            }
            let inPit = data.InPit ?? true
            let diffToAhead = Self.parseTime(data.TimeDiffToPositionAhead)
            let diffToFastest = Self.parseTime(data.TimeDiffToFastest)
            let state = DriverState(
                position: pos,
                inPit: inPit,
                diffToFastest: diffToFastest,
                diffToAhead: diffToAhead
            )
            driversStates[number] = state
        }
    }

    mutating func update(_ value: [JSONValue]) throws {
        guard value.count == 2 else {
            throw StateError.UpdateIncorrectSize
        }
        let first = value[0]
        let second = value[1]
        guard case .string(let key) = first else {
            throw StateError.KeyError(value)
        }
        switch key {
        case "TimingData":
            guard case .object(let timing) = second,
                let linesArray = timing["Lines"],
                case .object(let lines) = linesArray
            else {
                throw StateError.ValueError(value)
            }
            for (key, value) in lines {
                guard
                    let number = Int(key),
                    var state = driversStates[number],
                    case .object(let timing) = value
                else {
                    continue
                }
                
                for field in DriverStateFields.allCases {
                    let newValue = timing[field.rawValue] // optional
                    guard let newValue else {
                        continue
                    }
                    switch field {
                    case .InPit:
                        if case .bool(let boolVal) = newValue {
                            state.inPit = boolVal
                        } else {
                            throw StateError.ValueError([value])
                        }
                    case .Position:
                        if case .string(let posString) = newValue,
                           let posNumber = Int(posString) {
                            state.position = posNumber
                        } else {
                            throw StateError.ValueError([value])
                        }
                    case .TimeDiffToFastest:
                        if case .string(let timeString) = newValue{
                            let timeValue = Self.parseTime(timeString)
                            state.diffToFastest = timeValue
                        } else {
                            throw StateError.ValueError([value])
                        }
                    case .TimeDiffToPositionAhead:
                        if case .string(let timeString) = newValue{
                            let timeValue = Self.parseTime(timeString)
                            state.diffToAhead = timeValue
                        } else {
                            throw StateError.ValueError([value])
                        }
                    }
                }
            }
        default:
            return
        }
    }

    private static func parseTime(_ time: String?) -> Double {  // "+0.234"
        var timeCopy = time ?? ""
        if !timeCopy.isEmpty {
            timeCopy.removeFirst()  // +
        }
        return Double(timeCopy) ?? -1.0
    }
}




enum StateError: Error {
    case SessionInfoNotFound
    case DriversInfoNotFound
    case UpdateIncorrectSize
    case KeyError([JSONValue])
    case ValueError([JSONValue])
    case PositionZNotFound
    case CarDataZNotFound
    case TimingDataNotFound
}
