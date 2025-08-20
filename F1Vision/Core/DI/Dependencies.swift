//
//  Dependencies.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Swinject

class Dependencies {
    static let shared = Dependencies()
    private let container: Container = Container()

    private init() {
        setupDependencies()
    }

    private func setupDependencies() {
        // MARK: - Register Services

        // Register JSONDataService as singleton
        container.register(JSONDataProtocol.self) { _ in
            JSONDataService.shared
        }.inObjectScope(.container)

        container.register(TrackProtocol.self) { _ in
            TrackMock.init()
        }.inObjectScope(.container)
    }

    // MARK: - Resolution Methods

    /// Resolve a service by type
    func resolve<T>(_ serviceType: T.Type) -> T? {
        return container.resolve(serviceType)
    }

    /// Resolve a service by type (non-optional, will crash if not found)
    func resolve<T>(_ serviceType: T.Type) -> T {
        return container.resolve(serviceType)!
    }

    // MARK: - Convenience Methods

    /// Get JSONDataService
    var jsonDataService: JSONDataProtocol {
        return resolve(JSONDataProtocol.self)!
    }

    /// Get JSONDataService as concrete type
    var jsonDataServiceConcrete: JSONDataService {
        return resolve(JSONDataService.self)!
    }

    var track: TrackProtocol {
        return resolve(TrackProtocol.self)!
    }
}
