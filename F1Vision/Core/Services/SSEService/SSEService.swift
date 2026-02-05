//
//  SSEService.swift
//  F1Vision
//
//  Created by br3nd4nt on 17.12.2025.
//

import EventSource
import Puppy
import Foundation

@MainActor
// contains all of the race status, recieves updates and changes the values it has for viewmodels to recieve
final class SSEService: ObservableObject {
    private static let jsonDecoder = Dependencies.shared.jsonDecoder
    private let logger: Puppy = Dependencies.shared.logger
    private let urlRequest = URLRequest(url: Configuration.sseURL)
    private var connectionTask: Task<Void, Never>?
    
    @Published var state: SSEstate?
    @Published var gotInitialResponse: Bool = false
    
    @Published var hasError: Bool = false
    @Published var errorMessage: String?
    
    func makeConnection() {
        connectionTask?.cancel()
        connectionTask = Task { [weak self] in
            guard let self else { return }
            let eventSource = EventSource()
            let dataTask = eventSource.dataTask(for: urlRequest)
            
            await withTaskCancellationHandler {
                for await event in dataTask.events() {
                    if Task.isCancelled { break }
                    switch event {
                    case .open:
                        logger.info("Connection was opened.")
                        hasError = false
                        errorMessage = nil
                    case .error(let error):
                        logger.error("Received an error:\(error.localizedDescription)")
                        hasError = true
                        errorMessage = error.localizedDescription
                    case .event(let event):
                        handleEvent(event)
                    case .closed:
                        logger.warning("Connection was closed.")
                        hasError = true
                        errorMessage = "Connection closed."
                    }
                }
            } onCancel: {
                // ????
            }
        }
    }

    func reconnect() {
        hasError = false
        errorMessage = nil
        makeConnection()
    }
    
    private func handleEvent(_ event: any EVEvent) {
        guard let e = event.event,
              let data = event.data?.data(using: .utf8) else {
            return
        }
        switch e {
        case "initial":
            handleInitial(data)
        case "updates":
            handleUpdate(data)
        default:
            return
        }
    }
    
    private func handleInitial(_ data: Data) {
        do {
            let message = try Self.jsonDecoder.decode(SSEmessage.self, from: data)
            let state = try SSEstate(message)
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
    }
    
    private func handleUpdate(_ data: Data) {
        do {
            let message = try Self.jsonDecoder.decode([[JSONValue]].self, from: data)
            for update in message {
                DispatchQueue.main.async { [weak self] in
                    do {
                        try self?.state?.update(update)
                    } catch {
                        self?.logger.warning("Error updating state: \(error)")
                    }
                }
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
    }
}
