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

    @Published var isLoaded = false
    @Published var trackPoints: [CGPoint] = []
//    @Published var driverPoints: [TrackDriverPosition] = []

    @Published var viewSize: CGSize = .zero
    private let viewSizeSubject = PassthroughSubject<CGSize, Never>()
    
    private var rotatedTargetValues: [Double: TrackBoundBox] = [:]

    // Configuration
    private let zoom: Double = Configuration.zoom
    let driverPointSize = CGSize(width: 12, height: 12)

    // MARK: - Init

    init(sseService: SSEService, mapService: MapRequestService) {
        self.sseService = sseService
        self.mapService = mapService
        self.mapService.$response
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.translateTrackLayoutPoints()
            }
            .store(in: &cancellables)
//        self.socketService.$trackLayout
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] layout in
//                self?.logger.debug(String(describing: layout?.world_bounds))
//                self?.translateTrackLayoutPoints()
//            }
//            .store(in: &cancellables)
//        self.socketService.$snapshot
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.updateDrivers()
//            }
//            .store(in: &cancellables)
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

    private func translateTrackLayoutPoints() {
        isLoaded = false
        guard mapService.isLoaded,
        let response = mapService.response else {
            return
        }
        
        var defaultPoints: [CGPoint] = []
        for i in 0..<response.x.count {
            defaultPoints.append(CGPoint(x: response.x[i], y: response.y[i]))
        }
        defaultPoints.append(CGPoint(x: response.x[0], y: response.y[0]))
        
        let defaultBoundBox = getBoundBox(defaultPoints)
        
        // theoretically can take some time so better to do it in async dispatch queue
        self.getRotations(defaultPoints, defaultBoundBox)
        
        self.translatePoints(defaultPoints, box: defaultBoundBox)
        
    }
    
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
    
    //  clears any calculated rotations, so should only be called if new track data came through
    //  translatePoints should always be called after getRotations to update the published trackPoints accordingly.
    private func getRotations(_ defaultPoints: [CGPoint], _ defaultBoundBox: TrackBoundBox) {
        let center = defaultBoundBox.getCenterPoint()
        let rotation = Configuration.rotationAngle
        rotatedTargetValues = [:]
        
        for angle in stride(from: rotation, to: 90, by: rotation) {
            let rotatedPoints = rotatePoints(defaultPoints, around: center, angle: angle)
            let rotatedBoundBox = getBoundBox(rotatedPoints)
            rotatedTargetValues[angle] = rotatedBoundBox
        }
    }
    
    private func translatePoints(_ points: [CGPoint], box: TrackBoundBox) {
        var targetRatio = viewSize.height / viewSize.width
        if targetRatio.isNaN {
            targetRatio = 1
        }
        var bestAngle: Double = 0
        var bestBox = box
        var bestDiff = Double.greatestFiniteMagnitude
        
        for (angle, bbox) in rotatedTargetValues {
            let ratio = bbox.trackAspectRatio
            let diff = abs(ratio - targetRatio)
            if diff < bestDiff {
                bestDiff = diff
                bestAngle = angle
                bestBox = bbox
            }
        }
        let center = bestBox.getCenterPoint()
        let rotatedPoints = rotatePoints(points, around: center, angle: bestAngle)
        let translatedPoints = rotatedPoints.map {
            translatePoint(point: $0, box: bestBox)
        }
        trackPoints = translatedPoints
        isLoaded = true
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

    func sendViewSize(_ viewSize: CGSize) {
        DispatchQueue.main.async {
            self.viewSizeSubject.send(viewSize)
        }
    }
}
