//
//  TrackViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Foundation
import UIKit
import Combine

@MainActor
final class TrackViewModel: ObservableObject {
    // MARK: - Properties

    @Published var trackData: TrackLayoutModel?
    @Published var translatedPoints: [CGPoint] = []
    @Published var driverPositions: [DriverPosition] = []

    // Translation parameters
    private var boundingBox: BoundingBox = .init(minX: 0, minY: 0, maxX: 0, maxY: 0)
    private var trackWidth: Double = 0
    private var trackHeight: Double = 0
    private var lastTranslatedSize: CGSize = .zero

    // Configuration
    private let zoom: Double = Configuration.zoom

    // MARK: - Init

    init() {
        Task {
            await getTrackData()
        }
    }

    // MARK: - Data Loading

    func getTrackData() async {
        do {
            let data = try await Dependencies.shared.track.getTrackData()
            await MainActor.run {
                self.trackData = data
            }
        } catch {
            print("Failed to get track data: \(error)")
        }
    }

    // MARK: - Driver Position Management

    func updateDriverPositions(_ drivers: [DriverState]) {
        guard let trackData else {
            return
        }

        let newDriverPositions = drivers.map { driver in
            calculateDriverPosition(driver, trackData: trackData)
        }

        driverPositions = newDriverPositions

        // Update translated positions if view size is available
        if lastTranslatedSize != .zero {
            updateTranslatedDriverPositions()
        }
    }

    private func calculateDriverPosition(_ driver: DriverState, trackData: TrackLayoutModel) -> DriverPosition {
        // Find the track point closest to the driver's distance
        let targetDistance = driver.distance
        let trackPoints = trackData.points

        guard !trackPoints.isEmpty else {
            return DriverPosition(driver: driver, position: .zero, trackDistance: 0)
        }

        // Find the closest track point based on distance
        var closestPoint = trackPoints[0]
        var minDistance = abs(trackPoints[0].distance - targetDistance)

        for point in trackPoints {
            let distanceDiff = abs(point.distance - targetDistance)
            if distanceDiff < minDistance {
                minDistance = distanceDiff
                closestPoint = point
            }
        }

        return DriverPosition(
            driver: driver,
            position: CGPoint(x: closestPoint.x, y: closestPoint.y),
            trackDistance: closestPoint.distance
        )
    }

    private func updateTranslatedDriverPositions() {
        guard lastTranslatedSize != .zero else {
            return
        }

        for i in driverPositions.indices {
            let originalPosition = driverPositions[i].position
            let translatedPosition = translatePoint(
                TrackPoint(x: originalPosition.x, y: originalPosition.y, distance: 0),
                scaleFactor: calculateScaleFactor(for: lastTranslatedSize),
                viewSize: lastTranslatedSize
            )
            driverPositions[i].translatedPosition = translatedPosition
        }
    }

    // MARK: - Translation Logic

    func translatePoints(for viewSize: CGSize) {
        guard let data = trackData else {
            return
        }

        // Only translate if view size changed or we haven't translated yet
        guard lastTranslatedSize != viewSize || translatedPoints.isEmpty else {
            return
        }

        // Setup translation parameters
        setupTranslationParameters(data)

        // Calculate scale factor
        let scaleFactor = calculateScaleFactor(for: viewSize)

        // Translate all points
        let newTranslatedPoints = data.points.map { point in
            translatePoint(point, scaleFactor: scaleFactor, viewSize: viewSize)
        }

        translatedPoints = newTranslatedPoints

        // Update driver positions
        updateTranslatedDriverPositions()

        lastTranslatedSize = viewSize
    }

    private func setupTranslationParameters(_ data: TrackLayoutModel) {
        boundingBox = data.boundingBox
        trackWidth = boundingBox.maxX - boundingBox.minX
        trackHeight = boundingBox.maxY - boundingBox.minY
    }

    private func calculateScaleFactor(for viewSize: CGSize) -> Double {
        let trackAspectRatio = trackHeight / trackWidth
        let viewAspectRatio = viewSize.height / viewSize.width

        let scale: Double
        if viewAspectRatio > trackAspectRatio {
            scale = viewSize.width / trackWidth
        } else {
            scale = viewSize.height / trackHeight
        }

        return scale * zoom
    }

    private func translatePoint(_ point: TrackPoint, scaleFactor: Double, viewSize: CGSize) -> CGPoint {
        let translatedX = (point.x - boundingBox.minX) * scaleFactor
        let translatedY = (point.y - boundingBox.minY) * scaleFactor

        let trackWidthInView = trackWidth * scaleFactor
        let trackHeightInView = trackHeight * scaleFactor

        let centeredX = translatedX + (viewSize.width - trackWidthInView) / 2
        let centeredY = translatedY + (viewSize.height - trackHeightInView) / 2

        return CGPoint(x: centeredX, y: centeredY)
    }
}

// MARK: - Driver Position Model

struct DriverPosition: Identifiable {
    let id = UUID()
    let driver: DriverState
    let position: CGPoint
    let trackDistance: Double
    var translatedPosition: CGPoint = .zero

    var driverCode: String {
        driver.driverId.code
    }

    var teamColor: String {
        driver.driverId.teamColorHex
    }
}
