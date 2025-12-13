//
//  SocketSerivce.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.09.2025.
//
import Foundation
import Puppy
import Starscream

final class SocketService: WebSocketDelegate, ObservableObject {
    @Published var isConnected = false

    @Published var trackLayout: TrackLayout?
    @Published var snapshot: RaceSnapshot?
    @Published var driverColors: [DriverColor] = []

    private let logger: Puppy = Dependencies.shared.logger

    private var socket: WebSocket
    private let server = WebSocketServer()

    private static let jsonDecoder = Dependencies.shared.jsonDecoder

    init() {
        var request = URLRequest(url: Configuration.socketURL)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    deinit {
        socket.disconnect()
    }

    // MARK: - WebSocketDelegate
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            handleConnected(headers)
        case .disconnected(let reason, let code):
            handleDisconnected(reason: reason, code: code)
        case .text(let string):
            handleTextEvent(string)
        case .cancelled:
            handleCancelled()
        case .error(let error):
            isConnected = false
            handleError(error)
        case .peerClosed:
            break
        case .binary, .pong, .ping, .viabilityChanged, .reconnectSuggested:
            break
        }
    }

    private func handleConnected(_ headers: [String: String]) {
        isConnected = true
        logger.info("websocket connected")
        logger.debug("websocket headers: \(headers)")
    }

    private func handleDisconnected(reason: String, code: UInt16) {
        isConnected = false
        logger.info("websocket is disconnected with code \(code), reason: \(reason)")
    }

    private func handleTextEvent(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            logger.error("got incorrect data from websocket")
            logger.debug("websocket data: \(string)")
            return
        }
        do {
            let message = try Self.jsonDecoder.decode(WebsocketMessage.self, from: data)
            switch message {
            case .raceSnapshot(let newSnapshot):
                snapshot = newSnapshot
            case .trackLayout(let layout):
                trackLayout = layout
                logger.info("got track layout")
            case .colors(let colors):
                driverColors = colors.map { color in
                    DriverColor(color)
                }
                logger.info("got driver colors")
            }
        } catch {
            logger.error("got incorrect data from websocket")
            logger.debug("websocket data: \(string)")
        }
    }

    private func handleCancelled() {
        isConnected = false
        logger.warning("websocket connection cancelled")
    }

    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            logger.error("websocket encountered an error: \(e.message)")
        } else if let e = error {
            logger.error("websocket encountered an error: \(e.localizedDescription)")
        } else {
            logger.error("websocket encountered an error")
        }
    }
}
