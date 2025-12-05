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

    private static var socketAddress = "192.168.10.129"

    static var socketURL: URL {
        let url = URL(string: "ws://\(socketAddress):8000/ws")
        if let url {
            return url
        }
        logger.error("Error creating URL")
        fatalError("Error creating URL")
    }

    static let debugMode = false
    static let zoom = 0.95
}
