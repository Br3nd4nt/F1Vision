//
//  MapRequestService.swift
//  F1Vision
//
//  Created by br3nd4nt on 13.12.2025.
//

import Combine
import Foundation
import Puppy
import SwiftUI

@MainActor
final class MapRequestService: ObservableObject {
    private let logger: Puppy = Dependencies.shared.logger
    private static let jsonDecoder = Dependencies.shared.jsonDecoder

    private let sseService: SSEService
    private var cancellables = Set<AnyCancellable>()
    @Published var response: MapResponse?
    @Published var isLoaded = false

    @Published var isError = false
    @Published var errorMessage: String?
    
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
                    } catch {
                        self?.handleError(error)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchMapData() async throws {
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
            withAnimation {
                self.isLoaded = true
            }
            self.response = message
        }
    }
    
    func retry() {
        Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            do {
                try await fetchMapData()
                await MainActor.run {
                    withAnimation {
                        isError = false
                    }
                    errorMessage = nil
                }
            } catch {
                handleError(error)
            }
        }
    }

    private func handleError(_ error: Error) {
        let message: String
        switch error {
        case MapRequestServiceError.MissingSessionInfo:
            logger.error("No session data")
            message = "Missing session info. Try reconnecting."
        case let urlError as URLError:
            logger.error("Network error: \(urlError)")
            message = urlError.localizedDescription
        default:
            logger.error("Map request error: \(error)")
            message = error.localizedDescription
        }
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.isError = true
            }
            self?.errorMessage = message
        }
    }

    private func createRequestURL() throws -> URL {
        try Configuration.mapRequestBaseURL
            .appendingPathComponent(String(getTrackCode()))
            .appendingPathComponent("2026")
    }
    
    private func getTrackCode() throws -> Int {
        guard let key = sseService.state?.sessionInfo?.Meeting?.Circuit.Key else {
            logger.warning("no session info found")
            throw MapRequestServiceError.MissingSessionInfo
        }
        return key
    }
}

enum MapRequestServiceError: Error {
    case MissingSessionInfo
}
