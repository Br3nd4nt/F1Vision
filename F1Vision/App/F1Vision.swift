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
    @StateObject private var raceViewModel = RaceViewModel()
    @StateObject private var trackViewModel = TrackViewModel()

    var body: some View {
        HStack {
            RaceView(viewModel: raceViewModel, trackViewModel: trackViewModel)
            TrackView(viewModel: trackViewModel)
        }
        .accentColor(.red)
        .onAppear {
            // Connect the view models for data synchronization
            raceViewModel.setTrackViewModel(trackViewModel)
        }
    }
}

#Preview {
    ContentView()
}
