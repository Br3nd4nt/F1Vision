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
    // MARK: - Dependencies
    private let logger: Puppy = Dependencies.shared.logger
    private var cancellables = Set<AnyCancellable>()
    private var sseService: SSEService
    private var mapService: MapRequestService
    
    // MARK: - Track Layout Cache
    private var defaultTrackPoints: [CGPoint] = []
    private var defaultBoundBox: TrackBoundBox?
    
    // MARK: - Rotation Cache
    private var rotatedTargetValues: [Double: ([CGPoint], TrackBoundBox)] = [:]
    private var currentChosenAngle: Double = 0
    private var currentChosenBox: TrackBoundBox?
    private var currentRotatedPoints: [CGPoint] = []
    private let switchEpsilon: Double = 0.1
    
    // MARK: - Published State
    @Published var isLoaded = false
    @Published var trackPoints: [CGPoint] = []
    private static let defaultDriverPointColor: UIColor = Configuration.defaultDriverPointColor
    
    // MARK: - Driver State
    private var defaultDriverPoints: [Int: CGPoint] = [:]
    @Published var driverPoints: [Int: CGPoint] = [:]
    private var driversInfo: [Int: DriverFullInfo]?
    private var driversColors: [Int: UIColor]?
    
    // MARK: - View Sizing
    @Published var viewSize: CGSize = .zero
    private let viewSizeSubject = PassthroughSubject<CGSize, Never>()
    
    // MARK: - Configuration
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
            .assign(to: &$viewSize)
        
        $viewSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.translateTrackPoints()
            }
            .store(in: &cancellables)
        
        self.sseService.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.saveDriversInfo(state)
                self?.updateDriverPointsFromMiniSegments(state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func sendViewSize(_ viewSize: CGSize) {
        DispatchQueue.main.async {
            self.viewSizeSubject.send(viewSize)
        }
    }
    
    func getDriverColor(_ driver: Int) -> UIColor {
        guard let driversColors else { return Self.defaultDriverPointColor }
        if let color = driversColors[driver] {
            return color
        }
        return Self.defaultDriverPointColor
    }
    
    // MARK: - Data Handling
    
    private func saveDriversInfo(_ state: SSEstate?) {
        if driversInfo != nil {
            return
        }
        guard let state, let info = state.driversInfo else {
            return
        }
        driversInfo = info
        logger.info("driver info saved successfully")
        
        var colors = [Int: UIColor]()
        for (driver, info) in info {
            guard let hex = info.TeamColour else {
                continue
            }
            let color = UIColor(hex: hex)
            colors[driver] = color
        }
        driversColors = colors
    }
    
    private func recieveTrackLayout() {
        guard mapService.isLoaded,
              let response = mapService.response,
              response.x.count > 0 else {
            return
        }
        
        defaultTrackPoints = []
        for i in 0..<response.x.count {
            defaultTrackPoints.append(CGPoint(x: response.x[i], y: response.y[i]))
        }
        defaultTrackPoints.append(CGPoint(x: response.x[0], y: response.y[0]))
        
        defaultBoundBox = getBoundBox(defaultTrackPoints)
        
        self.getRotations()
        
        // need to get the initial points
        self.translateTrackPoints()
    }
    
    private func getRotations() {
        guard let box = self.defaultBoundBox, !defaultTrackPoints.isEmpty else { return }
        let center = box.getCenterPoint()
        let rotation = Configuration.rotationAngleStep
        rotatedTargetValues = [:]
        
        if !Configuration.enableTrackRotationCalculation {
            rotatedTargetValues[0] = (defaultTrackPoints, box)
            return
        }
        
        for angle in stride(from: rotation, to: 90, by: rotation) {
            let rotatedPoints = rotatePoints(defaultTrackPoints, around: center, angle: angle)
            let rotatedBoundBox = getBoundBox(rotatedPoints)
            rotatedTargetValues[angle] = (rotatedPoints, rotatedBoundBox)
        }
    }

    // MARK: - Track Transformation
    
    private func translateTrackPoints() {
        guard let box = self.defaultBoundBox, !defaultTrackPoints.isEmpty else { return }
        
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
        
        if let b = currentChosenBox, !currentRotatedPoints.isEmpty {
            if abs(currentChosenAngle - bestAngle) > 20 {
                bestBox = b
                bestPoints = currentRotatedPoints
                bestAngle = currentChosenAngle
            }
        }
        
        let translatedPoints = bestPoints.map {
            translatePoint(point: $0, box: bestBox)
        }
        trackPoints = translatedPoints
        isLoaded = true
        
        currentChosenAngle = bestAngle
        currentChosenBox = bestBox
        currentRotatedPoints = bestPoints
        
        updateDriverPointsFromMiniSegments(sseService.state)
    }
    
    private func updateDriverPointsFromMiniSegments(_ state: SSEstate?) {
         guard let state, !trackPoints.isEmpty else { return }
         let lastIndex = max(0, trackPoints.count - 1)
         var points: [Int: CGPoint] = [:]
         points.reserveCapacity(state.driversStates.count)

         for (driver, driverState) in state.driversStates {
             guard let progress = driverState.trackProgress else { continue }
             let raw = progress * Double(lastIndex)
             let index = max(0, min(Int(raw.rounded()), lastIndex))
             points[driver] = trackPoints[index]
         }

         driverPoints = points
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
    
    // MARK: - Rotation Helpers
    
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
    
    private func rotatePoint(_ point: CGPoint, around center: CGPoint, angle: Double) -> CGPoint {
        let cosA = cos(angle * .pi / 180)
        let sinA = sin(angle * .pi / 180)
        
        let translatedX = point.x - center.x
        let translatedY = point.y - center.y
        
        let rotatedX = translatedX * cosA - translatedY * sinA
        let rotatedY = translatedX * sinA + translatedY * cosA
        
        return CGPoint(x: rotatedX + center.x, y: rotatedY + center.y)
        
    }
    
    // MARK: - Bounding Box Helper
    
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
