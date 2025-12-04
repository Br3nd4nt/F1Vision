//
//  F1VisionApp.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.08.2025.
//

import SwiftUI
import Puppy

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
    @StateObject private var socketService: SocketService
    @ObservedObject private var trackViewModel: TrackViewModel
    @ObservedObject private var raceViewModel: RaceViewModel

    init() {
        let socketService = SocketService()
        _socketService = StateObject(wrappedValue: socketService)
        _trackViewModel = ObservedObject(wrappedValue: TrackViewModel(socketService))
        _raceViewModel = ObservedObject(wrappedValue: RaceViewModel(socketService))
    }

    var body: some View {
        HStack {
            RaceTableView(viewModel: raceViewModel)
            TrackView(viewModel: trackViewModel)
        }
        .accentColor(.red)
    }
}
