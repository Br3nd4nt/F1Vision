//
//  TrackMock.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

class TrackMock: TrackProtocol {

    private let json: JSONDataProtocol = Dependencies.shared.jsonDataService

    func getTrackPoints() -> TrackLayoutModel {
        let result = json.loadJSON(filename: "abu_dhabi_track_layout,json", as: ADModel.self) ?? ADModel(
            trackName: "",
            grandPrixName: "",
            trackPoints: [[]]
        )
        return .init(points: result.trackPoints)
    }
}

private struct ADModel: Codable {
    let trackName: String
    let grandPrixName: String
    let trackPoints: [[Int]]
}
