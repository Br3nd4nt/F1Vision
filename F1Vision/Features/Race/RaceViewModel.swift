//
//  RaceViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 23.08.2025.
//

import Combine
import Foundation
import Puppy
import SwiftUI

@MainActor
final class RaceViewModel: ObservableObject {
    private let logger: Puppy = Dependencies.shared.logger

    private var cancellables = Set<AnyCancellable>()
    private let sseService: SSEService

    @Published var isLoaded = false

    let tableColumnWidths: [Double] = [40, 60, 35]

    init(sseService: SSEService) {
        self.sseService = sseService
    }
}
