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

    var viewModel = TrackViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
            }
        }
    }
}
