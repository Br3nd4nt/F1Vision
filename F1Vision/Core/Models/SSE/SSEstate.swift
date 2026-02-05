//
//  State.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.01.2026.
//

import Foundation

@MainActor
struct SSEstate: Codable {
    private static let jsonDecoder = Dependencies.shared.jsonDecoder
    private static let decodingService = Dependencies.shared.zlibDecoder
    
    var position: Position
    var carData: CarData
    var driversOrder: [Int: Int]
    let sessionInfo: SessionInfo?
    let drivers: [Int: DriverFullInfo]?
    
    init(_ response: SSEmessage) throws {
        // session info
        guard let info = response.sessionInfo else {
            throw StateError.SessionInfoNotFound
        }
        sessionInfo = info
        
        // driver info
        guard let driverList = response.driverList else {
            throw StateError.DriversInfoNotFound
        }
        var infoList = [Int: DriverFullInfo]()
        for (driver, info) in driverList {
            guard let number = Int(driver) else {
                continue // ???
            }
            infoList[number] = info
        }
        drivers = infoList
        
        // position in space (coordinates)
        guard let positionZ = response.positionZ else {
            throw StateError.PositionZNotFound
        }
        guard let positionData = Self.decodingService.getBase64Decoded(positionZ) else {
            throw ZLibDecodingError.base64DecodingFailed
        }
        let inflatedPosition = try Self.decodingService.inflate(positionData)
        
        position = try Self.jsonDecoder.decode(Position.self, from: inflatedPosition)
        
        // car data
        guard let carDataZ = response.carDataZ else {
            throw StateError.CarDataZNotFound
        }
        
        guard let carDataData = Self.decodingService.getBase64Decoded(carDataZ) else {
            throw ZLibDecodingError.base64DecodingFailed
        }
        
        let inflatedCarData = try Self.decodingService.inflate(carDataData)
        
        carData = try Self.jsonDecoder.decode(CarData.self, from: inflatedCarData)
        
        // timing app data (drivers order)
        guard let timingAppData = response.timingAppData else {
            throw StateError.TimingAppDataNotFound
        }
        
        var order = [Int: Int]()
        for (key, value) in timingAppData.lines {
            guard let number = Int(key), let posString = value.gridPos, let pos = Int(posString) else {
                throw StateError.TimingAppDataNotFound
            }
            order[number] = pos
        }
        driversOrder = order
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
        case "positionZ":
            guard case .string(let positionZ) = second else {
                throw StateError.ValueError(value)
            }
            guard let data = Self.decodingService.getBase64Decoded(positionZ) else {
                throw ZLibDecodingError.base64DecodingFailed
            }
            let inflated = try Self.decodingService.inflate(data)
            position = try Self.jsonDecoder.decode(Position.self, from: inflated)
        case "carDataZ":
            guard case .string(let carDataZ) = second else {
                throw StateError.ValueError(value)
            }
            guard let data = Self.decodingService.getBase64Decoded(carDataZ) else {
                throw ZLibDecodingError.base64DecodingFailed
            }
            let inflated = try Self.decodingService.inflate(data)
            carData = try Self.jsonDecoder.decode(CarData.self, from: inflated)
        case "timingAppData":
            guard case .object(let timing) = second,
                  let linesArray = timing["lines"],
                  case .object(let lines) = linesArray else {
                throw StateError.ValueError(value)
            }
            for (key, value) in lines {
                guard
                    let number = Int(key),
                    case .object(let timing) = value,
                    let pos = timing["gridPos"],
                    case .int(let posNumber) = pos
                else {
                    continue
                }
                driversOrder[number] = posNumber
            }
        default:
            return
        }
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
    case TimingAppDataNotFound
}
