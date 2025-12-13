//
//  Configuration.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

import Foundation
import Puppy

struct Configuration {
    private static let logger: Puppy = Dependencies.shared.logger
    static let debugMode = true
    static let zoom = 0.95
    private static var socketHost = "localhost"
    private static var socketPath = "/ws"
    static var socketURL: URL {
        var components = URLComponents()
        components.scheme = "ws"
        components.host = socketHost
        components.path = socketPath
        let url = components.url
        if let url {
            return url
        }
        logger.error("Error creating websocket URL")
        fatalError("Error creating websocket URL")
    }

    private static let mapRequestHost = "api.multiviewer.app"
    private static let mapRequestPath = "/api/v1/circuits"
    static var mapRequestBaseURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = mapRequestHost
        components.path = mapRequestPath
        let url = components.url
        if let url {
            return url
        }
        logger.error("Error creating map request URL")
        fatalError("Error creating map request URL")
    }
}
