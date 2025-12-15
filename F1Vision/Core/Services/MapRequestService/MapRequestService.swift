//
//  MapRequestService.swift
//  F1Vision
//
//  Created by br3nd4nt on 13.12.2025.
//

import Combine
import Foundation
import Puppy

final class MapRequestService: ObservableObject {
    private let logger: Puppy = Dependencies.shared.logger
    private static let jsonDecoder = Dependencies.shared.jsonDecoder

    @Published var response: MapResponse?
    @Published var isLoaded = true

    func fetchMapData() async throws {
        let requestURL = createRequestURL()
        let (data, response) = try await URLSession.shared.data(from: requestURL)
        guard let http = response as? HTTPURLResponse,
              200 ..< 300 ~= http.statusCode
        else {
            logger.error("Got bad server response: \(response.description)")
            logger.error("Initial URL: \(requestURL)")
            throw URLError(.badServerResponse)
        }
        logger.debug(response.debugDescription)
        let message = try Self.jsonDecoder.decode(MapResponse.self, from: data)
        logger.info("Got track for \(message.location)")
        await MainActor.run {
            self.response = message
        }
    }

    private func createRequestURL() -> URL {
        ConfigurationParameters.mapRequestBaseURL
            .appendingPathComponent(String(getTrackCode()))
            .appendingPathComponent("2025")
    }

    private let possibleCodes = [
        2, 4, 6, 7, 9, 10, 14, 15, 19, 22, 23, 28, 34, 39, 46, 49, 55, 59,
        61, 63, 65, 70, 72, 79, 144, 146, 147, 148, 149, 150, 151, 152,
    ]
    var index = 0
    private func getTrackCode() -> Int {
//        possibleCodes.randomElement()!
        let val = possibleCodes[index]
        index = (index + 1) % possibleCodes.count
        return val
    }
}
