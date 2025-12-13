//
//  TrackViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Combine
import Foundation
import Puppy
import SwiftUI
import UIKit

// Only manages data for track - track layout, points, point transformation etc.
@MainActor
final class TrackViewModel: ObservableObject {
    // MARK: - Properties

    private let logger: Puppy = Dependencies.shared.logger

    private var cancellables = Set<AnyCancellable>()
    private var socketService: SocketService
    private var mapService: MapRequestService

    @Published var isLoaded = false
    @Published var trackPoints: [CGPoint] = []
    @Published var driverPoints: [TrackDriverPosition] = []

    @Published var viewSize: CGSize = .zero
    private let viewSizeSubject = PassthroughSubject<CGSize, Never>()

    // Configuration
    private let zoom: Double = ConfigurationParameters.zoom
    let driverPointSize = CGSize(width: 12, height: 12)

    // MARK: - Init

    init(socketService: SocketService, mapService: MapRequestService) {
        self.socketService = socketService
        self.mapService = mapService
        self.mapService.$box
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.translateTrackLayoutPoints()
            }
            .store(in: &cancellables)
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
            .assign(to: &$viewSize)
        $viewSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.translateTrackLayoutPoints()
            }
            .store(in: &cancellables)
    }

    // MARK: - points translation

    private func translatePoint(_ x: Double, _ y: Double, box: TrackBoundBox) -> CGPoint {
        let scale = box.getScale(for: viewSize) * zoom

        let translatedX = (x - box.x_min) * scale
        let translatedY = (y - box.y_min) * scale

        let xOffset = (viewSize.width - box.trackWidth * scale) / 2
        let yOffset = (viewSize.height - box.trackHeight * scale) / 2

        let centeredX = translatedX + xOffset
        let centeredY = translatedY + yOffset

        return CGPoint(x: centeredX, y: centeredY)
    }

    private func translateTrackLayoutPoints() {
        guard mapService.isLoaded,
              let response = mapService.response,
              let box = mapService.box
        else {
            isLoaded = false
            return
        }
        var points: [CGPoint] = []
        for i in 0 ..< response.x.count {
            points.append(translatePoint(response.x[i], response.y[i], box: box))
        }
        
        // some tracks have blank spaces around start line
        points.append(translatePoint(response.x[0], response.y[0], box: box))
        trackPoints = points
        isLoaded = true
    }

    func sendViewSize(_ viewSize: CGSize) {
        DispatchQueue.main.async {
            self.viewSizeSubject.send(viewSize)
        }
    }

    private func updateDrivers() {
        guard socketService.isConnected,
              let layout = socketService.trackLayout,
              let snapshot = socketService.snapshot
        else {
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
