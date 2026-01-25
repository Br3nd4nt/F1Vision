//
//  F1Vision.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.08.2025.
//

import Puppy
import SwiftUI

@main
struct F1Vision: App {
    private let logger: Puppy = Dependencies.shared.logger
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    private let logger: Puppy = Dependencies.shared.logger
    
    @StateObject private var sseService: SSEService
    @StateObject private var mapService: MapRequestService
    @ObservedObject private var trackViewModel: TrackViewModel
    @ObservedObject private var raceViewModel: RaceViewModel
    
    init() {
        let sseService = SSEService()
        _sseService = StateObject(wrappedValue: sseService)
        let mapService = MapRequestService(sseService: sseService)
        _mapService = StateObject(wrappedValue: mapService)
        _trackViewModel = ObservedObject(wrappedValue:
                                            TrackViewModel(
                                                sseService: sseService,
                                                mapService: mapService
                                            )
        )
        _raceViewModel = ObservedObject(wrappedValue: RaceViewModel(sseService: sseService))
    }
    
    var body: some View {
        HStack {
            TelemetryTableUIViewRepresentable(viewModel: raceViewModel)
                .frame(minWidth: 300, maxWidth: 400)
                .border(Configuration.debugMode ? Color.green : Color.clear)
            TrackView(viewModel: trackViewModel)
                .border(Configuration.debugMode ? Color.cyan : Color.clear)
        }
        .accentColor(.red)
        .background(Color(.background))
        .task {
            sseService.makeConnection()
        }
    }
}
