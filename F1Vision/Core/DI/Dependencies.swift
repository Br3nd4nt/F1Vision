//
//  Dependencies.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Swinject
import Puppy
import Foundation

final class Dependencies {
    static let shared = Dependencies()
    private let container = Container()

    private init() {
        setupDependencies()
    }

    private func setupDependencies() {
        // MARK: - Register Services

        // Logger
        let puppy: Puppy
        let formatter = LogFormatter()

        let console = ConsoleLogger("br3nd4nt.F1Vision.console", logLevel: .info, logFormat: formatter)

        let fileManager = FileManager.default
        let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = directoryURL.appendingPathComponent("f1vision.log")
        do {
            let file = try FileLogger(
                "br3nd4nt.F1Vision",
                logLevel: .debug,
                logFormat: formatter,
                fileURL: fileURL,
                filePermission: "600",
            )

            puppy = Puppy(loggers: [console, file])
        } catch {
            print("Couldnt create file logger: \(error)")
            puppy = Puppy(loggers: [console])
        }

        container.register(Puppy.self) {_ in
            puppy
        }
        .inObjectScope(.container)

        // Register JSONDataService as singleton
        container.register(JSONDataProtocol.self) { _ in
            JSONDataService.shared
        }
        .inObjectScope(.container)

        // Track
        container.register(TrackProtocol.self) { _ in
            TrackMock()
        }
        .inObjectScope(.container)

        // Race
        container.register(RaceProtocol.self) { _ in
            RaceMock()
        }
        .inObjectScope(.container)
    }

    // MARK: - Resolution Methods

    /// Resolve a service by type
    func resolve<T>(_ serviceType: T.Type) -> T? {
        container.resolve(serviceType)
    }

    /// Resolve a service by type (non-optional, will crash if not found)
    func resolve<T>(_ serviceType: T.Type) -> T {
        container.resolve(serviceType)!
    }

    // MARK: - Convenience Methods

    /// Get JSONDataService
    var jsonDataService: JSONDataProtocol {
        resolve(JSONDataProtocol.self)!
    }

    /// Get JSONDataService as concrete type
    var jsonDataServiceConcrete: JSONDataService {
        resolve(JSONDataService.self)!
    }

    var track: TrackProtocol {
        resolve(TrackProtocol.self)!
    }

    var race: RaceProtocol {
        resolve(RaceProtocol.self)!
    }

    var logger: Puppy {
        resolve(Puppy.self)!
    }
}
