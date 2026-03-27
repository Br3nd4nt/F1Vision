//
//  F1Vision.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.08.2025.
//

import Puppy
import SwiftUI
import UIKit

@main
struct F1Vision: App {
    private let logger: Puppy = Dependencies.shared.logger
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea(.all)
                ContentView()
            }
            .onAppear {
                configureWindowSizeRestrictions()
            }
        }
    }

    private func configureWindowSizeRestrictions() {
        #if targetEnvironment(macCatalyst)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first
        else { return }
        scene.sizeRestrictions?.minimumSize = Configuration.windowMinSize
        scene.sizeRestrictions?.maximumSize = Configuration.windowMaxSize
        #endif
    }
}

struct ContentView: View {
    private let logger: Puppy = Dependencies.shared.logger
    
    @StateObject private var sseService: SSEService
    @StateObject private var mapService: MapRequestService
    @ObservedObject private var trackViewModel: TrackViewModel
    @ObservedObject private var raceViewModel: RaceViewModel
    @State private var activeAlert: ServiceAlert?
    
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
        ZStack {
            if !mapService.isLoaded {
                VStack {
                    ProgressView()
                    Text("Getting stuff ready...")
                }
            } else {
                GeometryReader { proxy in
                    let tableHeight = TelemetryTableLayoutMetrics.tableHeight(availableHeight: proxy.size.height)
                    let tableWidth = TelemetryTableLayoutMetrics.tableWidth(tableHeight: tableHeight)
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            TelemetryTableUIViewRepresentable(viewModel: raceViewModel)
                                .frame(width: tableWidth)
                                .frame(height: tableHeight)
                                .border(Configuration.debugMode ? Color.green : Color.clear)
                            TrackView(viewModel: trackViewModel)
                                .border(Configuration.debugMode ? Color.cyan : Color.clear)
                                .frame(minWidth: 50)
                        }
                        ScrollView(.vertical, showsIndicators: true) {
                            VStack {
                                TelemetryTableUIViewRepresentable(viewModel: raceViewModel)
                                    .frame(width: tableWidth)
                                    .frame(height: tableHeight)
                                    .border(Configuration.debugMode ? Color.green : Color.clear)
                                TrackView(viewModel: trackViewModel)
                                    .frame(height: proxy.size.height)
                                    .border(Configuration.debugMode ? Color.cyan : Color.clear)
                            }
                        }
                    }
                }
            }
        }
        .task {
            sseService.makeConnection()
        }
        .onReceive(sseService.$hasError) { hasError in
            guard hasError else { return }
            let message = sseService.errorMessage ?? "An error occurred."
            activeAlert = .sse(message)
        }
        .onReceive(mapService.$isError) { isError in
            guard isError else { return }
            let message = mapService.errorMessage ?? "An error occurred."
            activeAlert = .map(message)
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .sse(let message):
                return Alert(
                    title: Text("Live Connection Error"),
                    message: Text(message),
                    primaryButton: .default(Text("Reconnect")) {
                        sseService.reconnect()
                    },
                    secondaryButton: .cancel()
                )
            case .map(let message):
                return Alert(
                    title: Text("Map Data Error"),
                    message: Text(message),
                    primaryButton: .default(Text("Retry")) {
                        mapService.retry()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

private enum ServiceAlert: Identifiable {
    case sse(String)
    case map(String)
    
    var id: String {
        switch self {
        case .sse(let message):
            return "sse:\(message)"
        case .map(let message):
            return "map:\(message)"
        }
    }
}
