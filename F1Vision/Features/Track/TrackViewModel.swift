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
    private var sseService: SSEService
    private var mapService: MapRequestService

    private var defaultPoints: [CGPoint] = []
    private var defaultBoundBox: TrackBoundBox?
    private var currentChosenAngle: Double = 0
    private let switchEpsilon: Double = 0.1
    
    @Published var isLoaded = false
    @Published var trackPoints: [CGPoint] = []

    @Published var viewSize: CGSize = .zero
    private let viewSizeSubject = PassthroughSubject<CGSize, Never>()
    
    private var rotatedTargetValues: [Double: ([CGPoint], TrackBoundBox)] = [:]

    // Configuration
    private let zoom: Double = Configuration.zoom
    let driverPointSize = CGSize(
        width: Configuration.driverPointRadius * 2,
        height: Configuration.driverPointRadius * 2
    )

    // MARK: - Init

    init(sseService: SSEService, mapService: MapRequestService) {
        self.sseService = sseService
        self.mapService = mapService
        
        self.mapService.$response
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.recieveTrackLayout()
            }
            .store(in: &cancellables)
        // passthrough object for view to send its size
        viewSizeSubject
            .removeDuplicates()
            .assign(to: &$viewSize)
        
        $viewSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.translatePoints()
            }
            .store(in: &cancellables)
    }
    
    // called when we first get the points data
    private func recieveTrackLayout() {
        guard mapService.isLoaded,
        let response = mapService.response,
        response.x.count > 0 else {
              return
          }
        
        defaultPoints = []
        for i in 0..<response.x.count {
            defaultPoints.append(CGPoint(x: response.x[i], y: response.y[i]))
        }
        defaultPoints.append(CGPoint(x: response.x[0], y: response.y[0]))
        
        defaultBoundBox = getBoundBox(defaultPoints)
        
        self.getRotations()
        
        // need to get the initial points
        self.translatePoints()
    }
    
    private func getRotations() {
        guard let box = self.defaultBoundBox, !defaultPoints.isEmpty else { return }
        let center = box.getCenterPoint()
        let rotation = Configuration.rotationAngle
        rotatedTargetValues = [:]
        
        for angle in stride(from: rotation, to: 90, by: rotation) {
            let rotatedPoints = rotatePoints(defaultPoints, around: center, angle: angle)
            let rotatedBoundBox = getBoundBox(rotatedPoints)
            rotatedTargetValues[angle] = (rotatedPoints, rotatedBoundBox)
        }
    }

    // MARK: - Public Methods

    func sendViewSize(_ viewSize: CGSize) {
        DispatchQueue.main.async {
            self.logger.debug("\(viewSize)")
            self.viewSizeSubject.send(viewSize)
        }
    }

    // MARK: - Track Transformation
    
    private func translatePoints() {
        guard let box = self.defaultBoundBox, !defaultPoints.isEmpty else { return }
        
        var targetRatio = viewSize.height / viewSize.width
        if targetRatio.isNaN {
            targetRatio = 1
        }

        var bestBox = box
        var bestPoints: [CGPoint] = []
        var bestDiff = Double.greatestFiniteMagnitude
        var bestAngle: Double = 0
        
        for (angle, (points, bbox)) in rotatedTargetValues {
            let ratio = bbox.trackAspectRatio
            let diff = abs(ratio - targetRatio)
            if diff < bestDiff {
                bestDiff = diff
                bestBox = bbox
                bestPoints = points
                bestAngle = angle
            }
        }
        // TODO: figure this stuff out
        if let a = rotatedTargetValues[currentChosenAngle], let b = rotatedTargetValues[bestAngle] {
            let d = abs(a.1.trackAspectRatio - b.1.trackAspectRatio)
            if d < switchEpsilon {
                // we do not change
                bestPoints = a.0
                bestBox = a.1
            } else {
                logger.error("\(d)")
            }
        }
        
        let translatedPoints = bestPoints.map {
            translatePoint(point: $0, box: bestBox)
        }
        trackPoints = translatedPoints
        isLoaded = true
    }
    
    private func translatePoint(point: CGPoint, box: TrackBoundBox) -> CGPoint {
        let scale = box.getScale(for: viewSize) * zoom

        let translatedX = (point.x - box.x_min) * scale
        let translatedY = (point.y - box.y_min) * scale

        let xOffset = (viewSize.width - box.trackWidth * scale) / 2
        let yOffset = (viewSize.height - box.trackHeight * scale) / 2

        let centeredX = translatedX + xOffset
        let centeredY = translatedY + yOffset

        return CGPoint(x: centeredX, y: centeredY)
    }
    
    private func rotatePoints(_ points: [CGPoint], around center: CGPoint, angle: Double) -> [CGPoint] {
        var result: [CGPoint] = []
        let cosA = cos(angle * .pi / 180)
        let sinA = sin(angle * .pi / 180)
        
        for point in points {
            let translatedX = point.x - center.x
            let translatedY = point.y - center.y
            
            let rotatedX = translatedX * cosA - translatedY * sinA
            let rotatedY = translatedX * sinA + translatedY * cosA
            
            result.append(CGPoint(x: rotatedX + center.x, y: rotatedY + center.y))
        }
        
        return result
    }
    
    // MARK: - Bounding Box Helpers

    private func getBoundBox(_ points: [CGPoint]) -> TrackBoundBox {
        var minX: Double = .greatestFiniteMagnitude
        var minY: Double = .greatestFiniteMagnitude
        var maxX: Double = -Double.greatestFiniteMagnitude
        var maxY: Double = -Double.greatestFiniteMagnitude
        
        for point in points {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }

        return TrackBoundBox(x_min: minX, x_max: maxX, y_min: minY, y_max: maxY)
    }
}
