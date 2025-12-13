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
        var request = URLRequest(url: ConfigurationParameters.socketURL)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    deinit {
        socket.disconnect()
    }

    // MARK: - WebSocketDelegate

    func didReceive(event: Starscream.WebSocketEvent, client _: Starscream.WebSocketClient) {
        switch event {
        case let .connected(headers):
            handleConnected(headers: headers)
        case let .disconnected(reason, code):
            handleDisconnected(reason: reason, code: code)
        case let .text(string):
            handleText(string: string)
        case .cancelled:
            handleCancelled()
        case let .error(error):
            handleError(error)
        case .peerClosed, .binary, .pong, .ping, .viabilityChanged, .reconnectSuggested:
            break
        }
    }

    private func handleConnected(headers: [String: String]) {
        isConnected = true
        logger.info("websocket connected")
        logger.debug("websocket headers: \(headers)")
    }

    private func handleDisconnected(reason: String, code: UInt16) {
        isConnected = false
        logger.info("websocket is disconnected with code \(code), reason: \(reason)")
    }

    private func handleText(string: String) {
        guard let data = string.data(using: .utf8) else {
            logger.error("got incorrect data from websocket")
            logger.debug("websocket data: \(string)")
            return
        }
        do {
            let message = try Self.jsonDecoder.decode(WebsocketMessage.self, from: data)
            switch message {
            case let .raceSnapshot(newSnapshot):
                snapshot = newSnapshot
            case let .trackLayout(layout):
                trackLayout = layout
                logger.info("got track layout")
            case let .colors(colors):
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
