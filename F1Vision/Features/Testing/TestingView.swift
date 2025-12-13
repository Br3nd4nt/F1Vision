//
//  TestingView.swift
//  F1Vision
//
//  Created by br3nd4nt on 13.12.2025.
//

import Puppy
import SwiftUI

struct TestingView: View {
    private let logger: Puppy = Dependencies.shared.logger

    @ObservedObject private var mapService: MapRequestService

    init(mapService: MapRequestService) {
        self.mapService = mapService
    }

    var body: some View {
        VStack {
            Text(mapService.response?.countryName ?? "Loading map data...")
            Button("Fetch map") {
                Task {
                    do {
                        try await mapService.fetchMapData()
                    } catch {
                        logger.error(error.localizedDescription)
                    }
                }
            }
        }
    }
}
