//
//  TrackViewModel.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Foundation
import Puppy
import UIKit

final class TrackViewModel {
    private let trackService: TrackProtocol = Dependencies.shared.track
    private let logger: Puppy = Dependencies.shared.logger

    @Published var trackData: TrackLayoutModel?
    @Published var translatedPoints: [CGPoint] = []

    // Translation parameters
    private var boundingBox: BoundingBox = .init(minX: 0, minY: 0, maxX: 0, maxY: 0)
    private var trackWidth: Double = 0
    private var trackHeight: Double = 0
    private var lastTranslatedSize: CGSize = .zero

    // Configuration
    private let zoom: Double = Configuration.zoom
    private let hitboxesEnabled: Bool = Configuration.isHitBoxesEnabled

    init() {
        Task {
            do {
                try await getTrackData()
                guard let data = trackData else {
                    throw TrackServiceError.noData
                }
                logger.info("Got track data")
                logger.debug("\(String(describing: data))")
            } catch {
                logger.error("Failed getting track data: \(error)")
            }
        }
    }

    func getTrackData() async throws {
        trackData = try await trackService.getTrackData()
    }

    // MARK: - Translation Logic

    func translatePoints(for viewSize: CGSize) {
        guard let data = trackData else {
            logger.warning("No track data available for translation")
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
        translatedPoints = data.points.map { point in
            translatePoint(point, scaleFactor: scaleFactor, viewSize: viewSize)
        }

        lastTranslatedSize = viewSize
        logger.info("Translated \(translatedPoints.count) points for size: \(viewSize)")
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

    // MARK: - Hitbox Support

    func getTranslatedBounds() -> CGRect? {
        guard !translatedPoints.isEmpty else {
            return nil
        }

        let minX = translatedPoints.map(\.x).min() ?? 0
        let maxX = translatedPoints.map(\.x).max() ?? 0
        let minY = translatedPoints.map(\.y).min() ?? 0
        let maxY = translatedPoints.map(\.y).max() ?? 0

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
