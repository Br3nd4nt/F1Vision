//
//  SSEService.swift
//  F1Vision
//
//  Created by br3nd4nt on 17.12.2025.
//

import EventSource
import Puppy
import Foundation

// contains all of the race status, recieves updates and changes the values it has for viewmodels to recieve
final class SSEService: ObservableObject {
    private static let jsonDecoder = Dependencies.shared.jsonDecoder
    private let logger: Puppy = Dependencies.shared.logger
    private let urlRequest = URLRequest(url: Configuration.sseURL)
    
    @Published var state: State?
    @Published var gotInitialResponse: Bool = false
    
    func makeConnection() {
        Task {
            let eventSource = EventSource()
            let dataTask = eventSource.dataTask(for: urlRequest)
            
            for await event in dataTask.events() {
                switch event {
                case .open:
                    logger.info("Connection was opened.")
                case .error(let error):
                    logger.error("Received an error:\(error.localizedDescription)")
                case .event(let event):
                    handleEvent(event)
                case .closed:
                    logger.warning("Connection was closed.")
                }
            }
        }
    }
    
    private func handleEvent(_ event: any EVEvent) {
        guard let e = event.event,
              let data = event.data?.data(using: .utf8) else {
            return
        }
        switch e {
        case "initial":
            do {
                let message = try Self.jsonDecoder.decode(InitialResponse.self, from: data)
                let state = try State(message)
                DispatchQueue.main.async { [weak self] in
                    self?.state = state
                    self?.gotInitialResponse = true
                    self?.logger.debug("state was set: \(String(describing: self?.gotInitialResponse))")
                }
            } catch let DecodingError.keyNotFound(key, context) {
                logger.error("Missing key: \(key.stringValue)")
                logger.error(context.debugDescription)
                logger.debug("Initial json: \(String(decoding: data, as: Unicode.UTF8.self))")
            } catch let DecodingError.typeMismatch(type, context) {
                logger.error("Type mismatch: \(type)")
                logger.error(context.debugDescription)
                logger.debug("Initial json: \(String(decoding: data, as: Unicode.UTF8.self))")
            } catch {
                logger.error("Other error: \(error)")
            }
        case "update":
            break
        default:
            return
        }
    }
}
