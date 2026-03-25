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
            let diffToAhead = data.IntervalToPositionAhead?.Value ?? data.TimeDiffToPositionAhead
            let diffToFastest = data.TimeDiffToFastest ?? data.GapToLeader
            let miniSegments = Self.extractMiniSegments(from: data.Sectors)
            let currentMiniSegment = Self.pickCurrentMiniSegment(from: miniSegments)
            let state = DriverState(
                position: pos,
                inPit: inPit,
                diffToFastest: diffToFastest,
                diffToAhead: diffToAhead,
                currentMiniSegment: currentMiniSegment,
                miniSegments: miniSegments
            )
            driversStates[number] = state
        }
    }

    mutating func update(key: String, value: JSONValue) throws {
        switch key {
        case "TimingData":
            guard case .object(let timing) = value,
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
                            throw StateError.ValueError(value)
                        }
                    case .Position:
                        if case .string(let posString) = newValue,
                           let posNumber = Int(posString) {
                            state.position = posNumber
                        } else if case .int(let posNumber) = newValue {
                            state.position = posNumber
                        } else {
                            throw StateError.ValueError(value)
                        }
                    case .TimeDiffToFastest, .GapToLeader:
                        state.diffToFastest = Self.extractStringValue(from: newValue) ?? state.diffToFastest
                    case .TimeDiffToPositionAhead, .IntervalToPositionAhead:
                        state.diffToAhead = Self.extractStringValue(from: newValue) ?? state.diffToAhead
                    }
                }

                if let sectorsValue = timing["Sectors"] {
                    let updatedSegments = Self.extractMiniSegmentUpdates(fromSectorsUpdate: sectorsValue)
                    if !updatedSegments.isEmpty {
                        for segment in updatedSegments {
                            var sectorMap = state.miniSegments[segment.sector] ?? [:]
                            sectorMap[segment.segment] = segment.status
                            state.miniSegments[segment.sector] = sectorMap
                        }
                        state.currentMiniSegment = Self.pickCurrentMiniSegment(from: state.miniSegments)
                    }
                }

                driversStates[number] = state
            }
        default:
            Self.logger.debug("unrecognised update key: \(key)")
            return
        }
    }

    private static func extractStringValue(from value: JSONValue) -> String? {
        switch value {
        case .string(let str):
            return str
        case .object(let obj):
            if let inner = obj["Value"], case .string(let str) = inner {
                return str
            }
            return nil
        case .null:
            return nil
        default:
            return nil
        }
    }

    private static func extractMiniSegments(from sectors: [TimingSector]?) -> [Int: [Int: Int]] {
        guard let sectors else { return [:] }
        var result: [Int: [Int: Int]] = [:]
        for (sectorIndex, sector) in sectors.enumerated() {
            guard let segments = sector.Segments else { continue }
            for (segmentIndex, segment) in segments.enumerated() {
                guard let status = segment.Status else { continue }
                var sectorMap = result[sectorIndex] ?? [:]
                sectorMap[segmentIndex] = status
                result[sectorIndex] = sectorMap
            }
        }
        return result
    }

    private static func pickCurrentMiniSegment(from miniSegments: [Int: [Int: Int]]) -> DriverMiniSegment? {
        var best: DriverMiniSegment?
        for (sectorIndex, segments) in miniSegments {
            for (segmentIndex, status) in segments where status != 0 {
                let candidate = DriverMiniSegment(sector: sectorIndex, segment: segmentIndex, status: status)
                if let bestVal = best {
                    if sectorIndex > bestVal.sector || (sectorIndex == bestVal.sector && segmentIndex > bestVal.segment) {
                        best = candidate
                    }
                } else {
                    best = candidate
                }
            }
        }
        return best
    }

    private static func extractMiniSegmentUpdates(fromSectorsUpdate sectorsValue: JSONValue) -> [DriverMiniSegment] {
        var updates: [DriverMiniSegment] = []

        func handleSegments(_ sectorIndex: Int, _ segmentsValue: JSONValue) {
            switch segmentsValue {
            case .object(let segmentsObj):
                for (segmentKey, segmentVal) in segmentsObj {
                    guard let segmentIndex = Int(segmentKey),
                          case .object(let segmentObj) = segmentVal,
                          let statusValue = segmentObj["Status"]
                    else { continue }
                    if case .int(let statusInt) = statusValue {
                        updates.append(.init(sector: sectorIndex, segment: segmentIndex, status: statusInt))
                    }
                }
            case .array(let segmentsArr):
                for (segmentIndex, segmentVal) in segmentsArr.enumerated() {
                    guard case .object(let segmentObj) = segmentVal,
                          let statusValue = segmentObj["Status"]
                    else { continue }
                    if case .int(let statusInt) = statusValue {
                        updates.append(.init(sector: sectorIndex, segment: segmentIndex, status: statusInt))
                    }
                }
            default:
                return
            }
        }

        switch sectorsValue {
        case .object(let sectorsObj):
            for (sectorKey, sectorVal) in sectorsObj {
                guard let sectorIndex = Int(sectorKey),
                      case .object(let sectorObj) = sectorVal,
                      let segmentsValue = sectorObj["Segments"]
                else { continue }
                handleSegments(sectorIndex, segmentsValue)
            }
        case .array(let sectorsArr):
            for (sectorIndex, sectorVal) in sectorsArr.enumerated() {
                guard case .object(let sectorObj) = sectorVal,
                      let segmentsValue = sectorObj["Segments"]
                else { continue }
                handleSegments(sectorIndex, segmentsValue)
            }
        default:
            return []
        }

        return updates
    }
}




enum StateError: Error {
    case SessionInfoNotFound
    case DriversInfoNotFound
    case ValueError(JSONValue)
    case PositionZNotFound
    case CarDataZNotFound
    case TimingDataNotFound
}
