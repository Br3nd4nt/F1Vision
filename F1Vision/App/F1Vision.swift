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

    @StateObject private var socketService: SocketService
    @StateObject private var mapService: MapRequestService
    @ObservedObject private var trackViewModel: TrackViewModel
    @ObservedObject private var raceViewModel: RaceViewModel

    init() {
        let socketService = SocketService()
        let mapService = MapRequestService()
        _mapService = StateObject(wrappedValue: mapService)
        _socketService = StateObject(wrappedValue: socketService)
        _trackViewModel = ObservedObject(wrappedValue:
                                            TrackViewModel(
                                                socketService: socketService,
                                                mapService: mapService
                                            )
        )
        _raceViewModel = ObservedObject(wrappedValue: RaceViewModel(socketService: socketService))
    }

    var body: some View {
        HStack {
            TestingView(mapService: mapService)
                .frame(minWidth: 200)
            TrackView(viewModel: trackViewModel)
        }
        //        HStack {
        //            TelemetryTableUIViewRepresentable(viewModel: raceViewModel)
        //                .frame(minWidth: 300, maxWidth: 400)
        //                .border(Configuration.debugMode ? Color.green : Color.clear)
        ////                .layoutPriority(1)
        //            TrackView(viewModel: trackViewModel)
        //                .border(Configuration.debugMode ? Color.cyan : Color.clear)
        ////                .layoutPriority(0)
        //        }
        //        .accentColor(.red)
        //        .background(Color(.background))
    }
}
