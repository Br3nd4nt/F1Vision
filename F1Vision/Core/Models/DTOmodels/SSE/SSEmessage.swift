//
//  InitialResponse.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

struct SSEmessage: Codable {
    var DriverList: [String: DriverFullInfo]?
//    var CarDataZ: String?
//    var PositionZ: String? // zlib encoded
    var sessionInfo: SessionInfo?
    var timingData: TimingData?
    var timingAppData: TimingAppData?
//    var ChampionshipPrediction: ChampionshipPrediction?
//    var ExtrapolatedClock: ExtrapolatedClock?
//    var Heartbeat: Heartbeat?
//    var LapCount: LapCount?
//    var RaceControlMessages: RaceControlMessages?
//    var SessionData: SessionData?
//    var SessionStatus: SessionStatus?
//    var TeamRadio: TeamRadio?
//    var TimingStats: TimingStats?
//    var TopThree: TopThree?
//    var TrackStatus: TrackStatus?
//    var WeatherData: WeatherData?

    private struct DynamicCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case DriverList
//        case CarDataZ
//        case PositionZ
        case sessionInfo = "SessionInfo"
        case timingData = "TimingData"
        case timingAppData = "TimingAppData"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.DriverList) {
            let nested = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .DriverList)
            var parsed = [String: DriverFullInfo]()

            for key in nested.allKeys {
                if key.stringValue == "_kf" {
                    continue
                }
                if let info = try? nested.decode(DriverFullInfo.self, forKey: key) {
                    parsed[key.stringValue] = info
                }
            }

            DriverList = parsed.isEmpty ? nil : parsed
        } else {
            DriverList = nil
        }

//        CarDataZ = try container.decodeIfPresent(String.self, forKey: .CarDataZ)
//        PositionZ = try container.decodeIfPresent(String.self, forKey: .PositionZ)
        sessionInfo = try container.decodeIfPresent(SessionInfo.self, forKey: .sessionInfo)
        timingData = try container.decodeIfPresent(TimingData.self, forKey: .timingData)
        timingAppData = try container.decodeIfPresent(TimingAppData.self, forKey: .timingAppData)
    }
}
