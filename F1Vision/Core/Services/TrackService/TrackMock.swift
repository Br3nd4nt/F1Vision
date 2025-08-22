//
//  TrackMock.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

final class TrackMock: TrackProtocol {
    private let json: JSONDataProtocol = Dependencies.shared.jsonDataService

    func getTrackData() -> TrackLayoutModel? {
        json.loadJSON(filename: "suzuka_track_layout", as: TrackLayoutModel.self)
    }
}
