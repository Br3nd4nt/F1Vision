//
//  Configuration.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

import Foundation
import UIKit
import Puppy

@MainActor
enum Configuration {
    static let debugMode: Bool = false
    static let zoom: Double = 0.9
    static let enableTrackRotationCalculation: Bool = false
    
    static let driverPointRadius: Double = 7

    private static var socketScheme = "http"
    private static var socketHost = "localhost"
    private static var socketPath = "/api/realtime"
    private static var socketPort = 4_000

    private static let mapRequestScheme = "https"
    private static let mapRequestHost = "api.multiviewer.app"
    private static let mapRequestPath = "/api/v1/circuits"
    
    static var sseURL: URL {
        var components = URLComponents()
        components.scheme   = socketScheme
        components.host     = socketHost
        components.port     = socketPort
        components.path     = socketPath
        let url = components.url
        if let url {
            return url
        }
        logger.error("Error creating websocket URL")
        fatalError("Error creating websocket URL")
    }
    
    static var mapRequestBaseURL: URL {
        var components = URLComponents()
        components.scheme   = mapRequestScheme
        components.host     = mapRequestHost
        components.path     = mapRequestPath
        let url = components.url
        if let url {
            return url
        }
        logger.error("Error creating map request URL")
        fatalError("Error creating map request URL")
    }
    
    private static let logger: Puppy = Dependencies.shared.logger
    static let defaultDriverPointColor: UIColor = .lightGray
    static let rotationAngleStep: Double = 0.5
}
