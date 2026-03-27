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
    let totalMiniSegments: Int
    let sectorStartIndex: [Int: Int]
    let sectorLength: [Int: Int]
    let sectorOrder: [Int]
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
        
        // timing app data - tires
        guard let timingAppData = response.timingAppData else {
            throw StateError.TimingAppDataNotFound
        }

        let topology = Self.computeMiniSegmentTopology(from: timingData)
        totalMiniSegments = topology.total
        sectorStartIndex = topology.sectorStartIndex
        sectorLength = topology.sectorLength
        sectorOrder = topology.sectorOrder

        driversStates = [:]
        for (driver, data) in timingData.Lines {
            guard let number = Int(driver), let pos = Int(data.Position) else {
                throw StateError.TimingDataNotFound
            }
            let inPit = data.InPit ?? true
            let diffToAhead = data.IntervalToPositionAhead?.Value ?? data.TimeDiffToPositionAhead
            let diffToFastest = data.TimeDiffToFastest ?? data.GapToLeader
            let miniSegments = Self.extractMiniSegments(from: data.Sectors)
            let currentMiniSegment = Self.computeCurrentMiniSegment(from: miniSegments, sectorStartIndex: sectorStartIndex, totalMiniSegments: totalMiniSegments)
            let trackProgress = Self.computeTrackProgress(
                currentMiniSegment: currentMiniSegment,
                sectorStartIndex: sectorStartIndex,
                totalMiniSegments: totalMiniSegments
            )
            var stints: [TireStint] = []
            if let stintsInfo = timingAppData.Lines[driver]?.Stints {
                for (index, s) in stintsInfo.enumerated() {
                    stints.append(.init(s, stintNumber: index))
                }
            } else {
                stints = [.init()]
            }
            
            let state = DriverState(
                position: pos,
                inPit: inPit,
                diffToFastest: diffToFastest,
                diffToAhead: diffToAhead,
                currentMiniSegment: currentMiniSegment,
                trackProgress: trackProgress,
                miniSegments: miniSegments,
                stints: stints
            )
            driversStates[number] = state
        }
    }

    mutating func update(key: String, value: JSONValue) throws {
        switch key {
        case "TimingAppData":
            guard case .object(let timingApp) = value,
                  let linesValue = timingApp["Lines"],
                  case .object(let lines) = linesValue
            else {
                throw StateError.ValueError(value)
            }
            
            for (driverKey, driverValue) in lines {
                guard let number = Int(driverKey),
                      var state = driversStates[number],
                      case .object(let driverObj) = driverValue
                else { continue }
                
                guard let stintsValue = driverObj["Stints"] else {
                    continue
                }
                
                Self.applyStintsUpdate(stintsValue, to: &state.stints)
                driversStates[number] = state
            }
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
                        // "Current" segment is defined as (last non-zero segment) + 1.
                        state.currentMiniSegment = Self.computeCurrentMiniSegment(
                            from: state.miniSegments,
                            sectorStartIndex: sectorStartIndex,
                            totalMiniSegments: totalMiniSegments
                        )
                        state.trackProgress = Self.computeTrackProgress(
                            currentMiniSegment: state.currentMiniSegment,
                            sectorStartIndex: sectorStartIndex,
                            totalMiniSegments: totalMiniSegments
                        )
                    }
                }

                driversStates[number] = state
            }
        default:
            Self.logger.debug("unrecognised update key: \(key)")
            return
        }
    }

    private static func applyStintsUpdate(_ stintsValue: JSONValue, to stints: inout [TireStint]) {
        func ensureIndex(_ index: Int) {
            if stints.isEmpty {
                stints = [.init()]
            }
            if index >= stints.count {
                for i in stints.count...index {
                    stints.append(.init(totalLaps: 0, compound: "UNDEFINED", newCompound: true, stintNumber: i))
                }
            }
        }
        
        func applyFields(_ fields: [String: JSONValue], stintIndex: Int) {
            ensureIndex(stintIndex)
            var current = stints[stintIndex]
            
            if let total = fields["TotalLaps"] {
                if case .int(let v) = total {
                    current.totalLaps = v
                } else if case .string(let s) = total, let v = Int(s) {
                    current.totalLaps = v
                }
            }
            
            if let compound = fields["Compound"], case .string(let s) = compound {
                current.compound = s.uppercased()
            }
            
            if let newVal = fields["New"] {
                switch newVal {
                case .bool(let b):
                    current.newCompound = b
                case .string(let s):
                    current.newCompound = (s == "true" || s == "1")
                case .int(let i):
                    current.newCompound = (i != 0)
                default:
                    break
                }
            }
            
            current.stintNumber = stintIndex
            stints[stintIndex] = current
        }
        
        switch stintsValue {
        case .object(let stintsObj):
            for (stintKey, stintVal) in stintsObj {
                guard let stintIndex = Int(stintKey),
                      case .object(let fields) = stintVal
                else { continue }
                applyFields(fields, stintIndex: stintIndex)
            }
        case .array(let stintsArr):
            for (stintIndex, stintVal) in stintsArr.enumerated() {
                guard case .object(let fields) = stintVal else { continue }
                applyFields(fields, stintIndex: stintIndex)
            }
        default:
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

    private static func computeCurrentMiniSegment(
        from miniSegments: [Int: [Int: Int]],
        sectorStartIndex: [Int: Int],
        totalMiniSegments: Int
    ) -> DriverMiniSegment? {
        guard totalMiniSegments > 0 else { return nil }

        func linearIndex(sector: Int, segment: Int) -> Int {
            (sectorStartIndex[sector] ?? 0) + segment
        }

        var lastNonZero: (sector: Int, segment: Int, status: Int, linear: Int)?
        for (sectorIndex, segments) in miniSegments {
            for (segmentIndex, status) in segments where status != 0 {
                let lin = linearIndex(sector: sectorIndex, segment: segmentIndex)
                if let current = lastNonZero {
                    if lin > current.linear {
                        lastNonZero = (sectorIndex, segmentIndex, status, lin)
                    }
                } else {
                    lastNonZero = (sectorIndex, segmentIndex, status, lin)
                }
            }
        }

        let nextLinear = ((lastNonZero?.linear ?? -1) + 1) % totalMiniSegments
        guard let (sector, segment) = linearToSectorSegment(nextLinear, sectorStartIndex: sectorStartIndex) else { return nil }
        let status = miniSegments[sector]?[segment] ?? 0
        return DriverMiniSegment(sector: sector, segment: segment, status: status)
    }

    private static func linearToSectorSegment(
        _ linear: Int,
        sectorStartIndex: [Int: Int]
    ) -> (Int, Int)? {
        let ordered = sectorStartIndex.keys.sorted()
        guard let lastSector = ordered.last else { return nil }
        var chosenSector = ordered[0]
        for sector in ordered {
            let start = sectorStartIndex[sector] ?? 0
            if start <= linear {
                chosenSector = sector
            } else {
                break
            }
        }
        let start = sectorStartIndex[chosenSector] ?? 0
        let segment = linear - start
        // Defensive: if linear is beyond last sector start (shouldn't happen if topology is correct)
        if chosenSector == lastSector && segment < 0 { return nil }
        return (chosenSector, segment)
    }

    private static func computeMiniSegmentTopology(from timingData: TimingData) -> (total: Int, sectorStartIndex: [Int: Int], sectorLength: [Int: Int], sectorOrder: [Int]) {
        // Derive a stable "track topology" by taking the maximum segment count per sector
        // across all drivers. This avoids relying on dictionary iteration order (random driver).
        var maxSegmentsBySector: [Int: Int] = [:]

        for line in timingData.Lines.values {
            guard let sectors = line.Sectors else { continue }
            for (sectorIndex, sector) in sectors.enumerated() {
                let count = sector.Segments?.count ?? 0
                if count > (maxSegmentsBySector[sectorIndex] ?? 0) {
                    maxSegmentsBySector[sectorIndex] = count
                }
            }
        }

        guard !maxSegmentsBySector.isEmpty else { return (0, [:], [:], []) }

        let sortedSectorIndices = maxSegmentsBySector.keys.sorted()
        var total = 0
        var sectorStartIndex: [Int: Int] = [:]
        var sectorLength: [Int: Int] = [:]
        for sectorIndex in sortedSectorIndices {
            sectorStartIndex[sectorIndex] = total
            let len = maxSegmentsBySector[sectorIndex] ?? 0
            sectorLength[sectorIndex] = len
            total += len
        }

        return (total, sectorStartIndex, sectorLength, sortedSectorIndices)
    }

    private static func computeTrackProgress(
        currentMiniSegment: DriverMiniSegment?,
        sectorStartIndex: [Int: Int],
        totalMiniSegments: Int
    ) -> Double? {
        guard let currentMiniSegment,
              totalMiniSegments > 0,
              let start = sectorStartIndex[currentMiniSegment.sector]
        else { return nil }

        let linearIndex = start + currentMiniSegment.segment
        let clamped = max(0, min(linearIndex, max(0, totalMiniSegments - 1)))
        return Double(clamped) / Double(max(1, totalMiniSegments - 1))
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
    case TimingAppDataNotFound
}
