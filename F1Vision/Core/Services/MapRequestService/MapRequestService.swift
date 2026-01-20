//
//  MapRequestService.swift
//  F1Vision
//
//  Created by br3nd4nt on 13.12.2025.
//

import Combine
import Foundation
import Puppy

@MainActor
final class MapRequestService: ObservableObject {
    private let logger: Puppy = Dependencies.shared.logger
    private static let jsonDecoder = Dependencies.shared.jsonDecoder

    private let sseService: SSEService
    private var cancellables = Set<AnyCancellable>()
    @Published var response: MapResponse?
    @Published var isLoaded = false
    @Published var isError = false
    
    init(sseService: SSEService) {
        self.sseService = sseService
        self.sseService.$gotInitialResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard value else {
                    return
                }
                Task(priority: .userInitiated) {
                    do {
                        try await self?.fetchMapData()
                    } catch MapRequestServiceError.MissingSessionInfo {
                        self?.logger.error("No session data")
                        DispatchQueue.main.async { [weak self] in
                            self?.isError = true
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchMapData() async throws {
        self.isLoaded = false
        guard sseService.gotInitialResponse, sseService.state != nil else {
            logger.warning("no initial")
            return
        }
        logger.info("creating url")
        let requestURL = try createRequestURL()
        logger.info(requestURL.absoluteString)
        let (data, response) = try await URLSession.shared.data(from: requestURL)
        guard let http = response as? HTTPURLResponse,
              200 ..< 300 ~= http.statusCode
        else {
            logger.error("Got bad server response: \(response.description)")
            logger.error("Initial URL: \(requestURL)")
            throw URLError(.badServerResponse)
        }
        let message = try Self.jsonDecoder.decode(MapResponse.self, from: data)
        logger.info("Got track for \(message.location)")
        await MainActor.run {
            self.isLoaded = true
            self.response = message
        }
    }

    private func createRequestURL() throws -> URL {
        try Configuration.mapRequestBaseURL
            .appendingPathComponent(String(getTrackCode()))
            .appendingPathComponent("2025")
    }
    
    private func getTrackCode() throws -> Int {
        guard let key = sseService.state?.sessionInfo?.meeting?.circuit.key else {
            logger.warning("no session info found")
            throw MapRequestServiceError.MissingSessionInfo
        }
        return key
    }
}

enum MapRequestServiceError: Error {
    case MissingSessionInfo
}
