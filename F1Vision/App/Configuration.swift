//
//  Configuration.swift
//  F1Vision
//
//  Created by br3nd4nt on 22.08.2025.
//

import UIKit

enum Configuration {
    static let debugMode: Bool = false
    static let zoom: Double = 0.9
    static let enableTrackRotationCalculation: Bool = true

    // UI scaling clamps (used by telemetry cells/table sizing)
    static let uiReferenceRowHeight: Double = 32
    static let uiMinScale: Double = 0.75
    // Caps font size scaling inside cells.
    static let uiMaxTextScale: Double = 1.25
    // Caps table rowHeight scaling (table can grow beyond text cap).
    static let uiMaxTableScale: Double = 1.6
    
    #if targetEnvironment(macCatalyst)
    static let windowMinSize = CGSize(width: 980, height: 650)
    static let windowMaxSize = CGSize(width: 2160, height: 1440)
    #endif
    
    static let driverPointRadius: Double = 7

    private static let socketScheme = "http"
    private static let socketHost = "127.0.0.1"
    private static let socketPath = "/api/realtime"
    private static let socketPort = 4_000

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
        fatalError("Error creating map request URL")
    }
    
    static let defaultDriverPointColor: UIColor = .lightGray
    static let rotationAngleStep: Double = 0.5
}
