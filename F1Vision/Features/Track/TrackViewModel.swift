//
//  TrackViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Foundation
import UIKit
import Combine
import Puppy
import SwiftUI

// Only manages data for track - track layout, points, point transformation etc.
@MainActor
final class TrackViewModel: ObservableObject {
    // MARK: - Properties

    private let logger: Puppy = Dependencies.shared.logger

    private var cancellables = Set<AnyCancellable>()
    private var socketService: SocketService

    @Published var isLoaded = false
    @Published var trackPoints: [CGPoint] = []
    @Published var driverPoints: [TrackDriverPosition] = []

    @Published var viewSize: CGSize = .zero
    private let viewSizeSubject = PassthroughSubject<CGSize, Never>()

    // Configuration
    private let zoom: Double = Configuration.zoom

    let driverPointSize = CGSize(width: 8, height: 8)

    // MARK: - Init

    init(_ socketService: SocketService) {
        self.socketService = socketService
        self.socketService.$trackLayout
            .receive(on: DispatchQueue.main)
            .sink { [weak self] layout in
                self?.logger.debug(String(describing: layout?.world_bounds))
                self?.translateTrackLayoutPoints()
            }
            .store(in: &cancellables)
        self.socketService.$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDrivers()
            }
            .store(in: &cancellables)
        viewSizeSubject
            .removeDuplicates()
            .debounce(for: .milliseconds(0), scheduler: RunLoop.main)
            .assign(to: &$viewSize)
        $viewSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.translateTrackLayoutPoints()
            }
            .store(in: &cancellables)
    }

    // MARK: - points translation
    private func translatePoint(_ point: TrackPoint, layout: TrackLayout) -> CGPoint {
        let box = layout.world_bounds
        let scale = box.getScale(for: viewSize) * zoom

        let translatedX = (point.x - box.x_min) * scale
        let translatedY = (point.y - box.y_min) * scale

        let xOffset = (viewSize.width - box.trackWidth * scale) / 2
        let yOffset = (viewSize.height - box.trackHeight * scale) / 2

        let centeredX = translatedX + xOffset
        let centeredY = translatedY + yOffset

        return CGPoint(x: centeredX, y: centeredY)
    }

    private func translateTrackLayoutPoints() {
        guard socketService.isConnected,
        let layout = socketService.trackLayout,
        !layout.track_points.isEmpty else {
            isLoaded = false
            return
        }
        isLoaded = true
        trackPoints = layout.track_points.map { point in
            translatePoint(point, layout: layout)
        }
    }

    func sendViewSize(_ viewSize: CGSize) {
        viewSizeSubject.send(viewSize)
    }

    private func updateDrivers() {
        guard socketService.isConnected,
        let layout = socketService.trackLayout,
        let snapshot = socketService.snapshot else {
            return
        }
        driverPoints = snapshot.drivers
            .filter { driver in
                driver.speed > 0
            }
            .map { driver in
                let point = calculateDriverPosition(driver, layout: layout)
                let color = socketService.driverColors.first { color in
                    color.code == driver.code
                }?.color ?? UIColor.cyan
                return TrackDriverPosition(name: driver.code, point: point, color: color)
            }
    }

    private func calculateDriverPosition(_ driver: DriverState, layout: TrackLayout) -> CGPoint {
        let distance = driver.dist.truncatingRemainder(dividingBy: layout.distance)
        let mockPoint = TrackPoint(with: distance)
        let index = layout.track_points.binarySearch(for: mockPoint)
        let point = trackPoints[index]
        return CGPoint(x: point.x - driverPointSize.width / 2, y: point.y - driverPointSize.height / 2)
    }
}
