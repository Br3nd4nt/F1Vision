//
//  TrackMapView.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.12.2024.
//

// import Foundation
// import UIKit
// import Combine
//
// final class TrackMapView: UIView {
//    // TODO: move translation to VM
//    private let loadingLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Loading..."
//        label.textAlignment = .center
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .systemGray
//        return label
//    }()
//    
//    private let mapLayer: CAShapeLayer = CAShapeLayer()
//    private let mapBezierPath: UIBezierPath = UIBezierPath()
//    private var trackData: TrackInfo? = nil
//    private var trackPoints: [CGPoint] = []
//    
//    private let zoom: CGFloat = 0.9
//    
//    private struct TranslationParams {
//        static var minX: CGFloat = 1e6
//        static var maxX: CGFloat = -1e6
//        static var minY: CGFloat = 1e6
//        static var maxY: CGFloat = -1e6
//        
//        static var trackWidth: CGFloat = 0
//        static var trackHeight: CGFloat = 0
//        
//        static var trackAspectRatio: CGFloat = 1
//        static var viewAspectRatio: CGFloat = 1
//        
//        static var scale: CGFloat = 1
//        
//        static var translatedMinX: CGFloat = 1e6
//        static var translatedMaxX: CGFloat = -1e6
//        static var translatedMinY: CGFloat = 1e6
//        static var translatedMaxY: CGFloat = -1e6
//    }
//    
//    // only for debugging!
//    private let hitboxesEnabled: Bool = true
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureUI()
//    }
//    
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func configureUI() {
//        self.addSubview(loadingLabel)
//        loadingLabel.pinCenter(to: self)
//
//        self.layer.addSublayer(mapLayer)
//        
//        loadingLabel.isHidden = false
//        mapLayer.isHidden = true
//    }
//    
//    func setupMap() {
//        if trackData == nil {
//            print("[TrackMapView] No track data provided")
//            return
//        }
//        setupTranslationParameters()
//        guard let data: TrackInfo = self.trackData else {
//            print("[TrackMapView] No track data provided")
//            return
//        }
//        print("Setting up trackMapView")
//        trackPoints = []
//        print("Len of trackPoints: \(data.trackPoints.count)")
//        for point in data.trackPoints {
//            trackPoints.append(translatePoint(coordinates: point))
//        }
//        mapBezierPath.move(to: trackPoints[0])
//        for point in trackPoints[1...] {
//            mapBezierPath.addLine(to: point)
//        }
//        
//        mapLayer.strokeColor = UIColor.lightGray.cgColor
//        mapLayer.path = mapBezierPath.cgPath
//        mapLayer.fillColor = UIColor.clear.cgColor
//        
//        mapLayer.lineWidth = 5
//        
//        if hitboxesEnabled {
//            setupHitboxes()
//        }
//        mapLayer.isHidden = false
//        loadingLabel.isHidden = true
//        print("trackMapView been setup")
//    }
//    
//    func updateTrackData(_ newTrackData: TrackInfo) {
//        trackData = newTrackData
//    }
//    
//    private func setupTranslationParameters() {
//        guard let data: TrackInfo = self.trackData else {
//            return
//        }
//        
//        for point in data.trackPoints {
//            TranslationParams.minX = min(TranslationParams.minX, CGFloat(point[0]))
//            TranslationParams.maxX = max(TranslationParams.maxX, CGFloat(point[0]))
//            TranslationParams.minY = min(TranslationParams.minY, CGFloat(point[1]))
//            TranslationParams.maxY = max(TranslationParams.maxY, CGFloat(point[1]))
//        }
//        
//        TranslationParams.trackWidth = TranslationParams.maxX - TranslationParams.minX
//        TranslationParams.trackHeight = TranslationParams.maxY - TranslationParams.minY
//        
//        TranslationParams.trackAspectRatio = TranslationParams.trackHeight / TranslationParams.trackWidth
//        TranslationParams.viewAspectRatio = self.bounds.height / self.bounds.width
//        
//        TranslationParams.scale = {
//            if TranslationParams.viewAspectRatio > TranslationParams.trackAspectRatio {
//                return self.bounds.width / TranslationParams.trackWidth
//            } else {
//                return self.bounds.height / TranslationParams.trackHeight
//            }
//        }()
//    }
//    
//    private func translatePoint(coordinates: [Int]) -> CGPoint {
//        // TODO: add rotation to find best angle with lowest aspect ratio difference
//        let translatedX = (CGFloat(coordinates[0]) - TranslationParams.minX) * TranslationParams.scale * zoom
//        let translatedY = (CGFloat(coordinates[1]) - TranslationParams.minY) * TranslationParams.scale * zoom
//        
//        let centeredX = translatedX + self.bounds.width / 2 - (TranslationParams.maxX - TranslationParams.minX) * TranslationParams.scale * zoom / 2
//        let centeredY = translatedY + self.bounds.height / 2 - (TranslationParams.maxY - TranslationParams.minY) * TranslationParams.scale * zoom / 2
//        
//        // TODO: fix this
//        if hitboxesEnabled {
//            TranslationParams.translatedMinX = min(TranslationParams.minX, translatedX)
//            TranslationParams.translatedMaxX = max(TranslationParams.maxX, translatedX)
//            TranslationParams.translatedMinY = min(TranslationParams.minY, translatedY)
//            TranslationParams.translatedMaxY = max(TranslationParams.maxY, translatedY)
//        }
//        return CGPoint(x: centeredX, y: centeredY)
//    }
//    
//    private func setupHitboxes() {
//        if !hitboxesEnabled {
//            return
//        }
//        let box: CGRect = CGRect(x: TranslationParams.translatedMinX,
//                                 y: TranslationParams.translatedMinY,
//                                 width: TranslationParams.translatedMaxX - TranslationParams.translatedMinX,
//                                 height: TranslationParams.translatedMaxY - TranslationParams.translatedMinY)
//        
//        let boxLayer: CAShapeLayer = CAShapeLayer()
//        boxLayer.path = UIBezierPath(rect: box).cgPath
//        boxLayer.fillColor = UIColor.clear.cgColor
//        boxLayer.strokeColor = UIColor.systemPink.cgColor
//        
//        mapLayer.addSublayer(boxLayer)
//        
//        let viewBox: CGRect = CGRect(x: 0,
//                                     y: 0,
//                                     width: bounds.width,
//                                     height: bounds.height)
//        print(box)
//        print(viewBox)
//        let viewBoxLayer: CAShapeLayer = CAShapeLayer()
//        viewBoxLayer.path = UIBezierPath(rect: viewBox).cgPath
//        viewBoxLayer.fillColor = UIColor.clear.cgColor
//        viewBoxLayer.strokeColor = UIColor.systemCyan.cgColor
//        
//        boxLayer.addSublayer(viewBoxLayer)
//    }
// }
