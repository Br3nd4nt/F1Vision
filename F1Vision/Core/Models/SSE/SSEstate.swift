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
    
    var position: Position
    var carData: CarData
    var driversOrder: [Int: Int]
    let sessionInfo: SessionInfo?
    let drivers: [Int: DriverFullInfo]?
    
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
                continue // ???
            }
            infoList[number] = info
        }
        drivers = infoList
        
        // position in space (coordinates)
        position = Position(Position: [])
//        guard let positionZ = response.PositionZ else {
//            throw StateError.PositionZNotFound
//        }
//        guard let positionData = Self.decodingService.getBase64Decoded(positionZ) else {
//            throw ZLibDecodingError.base64DecodingFailed
//        }
//        let inflatedPosition = try Self.decodingService.inflate(positionData)
//        
//        position = try Self.jsonDecoder.decode(Position.self, from: inflatedPosition)
        
        // car data
//        guard let carDataZ = response.CarDataZ else {
//            throw StateError.CarDataZNotFound
//        }
//        
//        guard let carDataData = Self.decodingService.getBase64Decoded(carDataZ) else {
//            throw ZLibDecodingError.base64DecodingFailed
//        }
//        
//        let inflatedCarData = try Self.decodingService.inflate(carDataData)
//        
//        carData = try Self.jsonDecoder.decode(CarData.self, from: inflatedCarData)
        carData = CarData(Entries: [])
        
        // timing data (drivers order)
        guard let timingData = response.timingData else {
            throw StateError.TimingDataNotFound
        }
        
        var order = [Int: Int]()
        for (driver, data) in timingData.Lines {
            guard let number = Int(driver), let pos = Int(data.Position) else {
                throw StateError.TimingDataNotFound
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
        case "timingData":
            guard case .object(let timing) = second,
                  let linesArray = timing["lines"],
                  case .object(let lines) = linesArray else {
                throw StateError.ValueError(value)
            }
            for (key, value) in lines {
                guard
                    let number = Int(key),
                    case .object(let timing) = value,
                    let pos = timing["position"],
                    case .string(let posString) = pos,
                    let posNumber = Int(posString)
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
    case TimingDataNotFound
}
