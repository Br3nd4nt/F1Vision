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

    init() {
        let socketService = SocketService()
        _socketService = StateObject(wrappedValue: socketService)
        _trackViewModel = ObservedObject(wrappedValue: TrackViewModel(socketService))
    }

    var body: some View {
        HStack {
            Text("table goes here")
            TrackView(viewModel: trackViewModel)
        }
        .accentColor(.red)
    }
}
// #Preview {
//    ContentView()
// }
