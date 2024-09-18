//
//  TrackView.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.08.2024.
//

import Foundation
import UIKit

class TrackView: UIView {
    let textView: UILabel = UILabel()
    
    private let viewModel: TrackViewModel = TrackViewModel()
    
    var targetRatio: CGFloat = 0;
    
    private var bp = UIBezierPath()
    private let shapeLayer = CAShapeLayer()
    
    private let zoom: CGFloat = 0.95
    private let hitboxesEnabled: Bool = false
    public var trackGP: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("in frame")
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("in coder")
        configureUI()
    }
    
    private func configureUI() {
        
        self.addSubview(textView)
        textView.pinCenter(to: self)
        textView.textColor = .systemMint
        textView.font = .systemFont(ofSize: 20)
        textView.text = "TEST"
        
        self.layer.addSublayer(shapeLayer)
        shapeLayer.backgroundColor = UIColor.systemPink.cgColor
        shapeLayer.isHidden = true
        textView.isHidden = false
    }
    
    func connectToServer(completion: @escaping () -> Void) {
        print("connection to socket")
        viewModel.trackGP = self.trackGP
        viewModel.targetRatio = self.targetRatio
        viewModel.connect(completion: {model in
            print("got the model!")
            print("number of sectors: \(String(describing: model?.sectors.count))")
            
            // create the view
            if model!.sectors.count != 0 {
                self.configureTrack(model: model!)
            }
            completion()
        })
    }
    
    func drawDriver(driver: DriverData) {
        return
//        if trackGP.isEmpty{
//            return
//        }
//        
//        let radius: CGFloat = 7
//        let newCoords = self.translatePoint(x: Int(driver.coordinates.x), y: Int(driver.coordinates.y), minX: minX, maxX: maxX, minY: minY, maxY: maxY, width: width, height: height, zoom: scale)
//        print("drawing: \(driver.dirverInitials) at \(newCoords)")
//        let ovalPath = UIBezierPath(ovalIn: CGRectMake(newCoords.x + radius, newCoords.y + radius, 2 * radius, 2 * radius))
//        
//        let driverLayer: CAShapeLayer = CAShapeLayer()
//        driverLayer.path = ovalPath.cgPath
//        driverLayer.fillColor = UIColor.systemMint.cgColor
//        driverLayer.strokeColor = UIColor.systemPink.cgColor
//        
//        shapeLayer.addSublayer(driverLayer)
    }
    
    func configureTrack(model: TrackModel) {
        let translatedPoints: [CGPoint] = translateAllPoints(model)
        
        bp.move(to: translatedPoints.first!)
        for point in translatedPoints {
            bp.addLine(to: point)
        }
        bp.addLine(to: translatedPoints.first!)
        
        if hitboxesEnabled {
            drawBorders(model)
        }
        
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.path = bp.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.lineWidth = 5

        textView.isHidden = true
        shapeLayer.isHidden = false

    }
    
    func reset() {
        shapeLayer.isHidden = true
        textView.isHidden = false
        bp = UIBezierPath()
        self.shapeLayer.sublayers = nil
        self.shapeLayer.path = nil
        self.trackGP = ""
        viewModel.trackGP = ""
        viewModel.trackSectors = TrackModel(sectors: [])
    }
    
//    private func translatePoint(x: Int, y: Int, minX: Int, maxX: Int, minY: Int, maxY: Int, width trackViewWidth: CGFloat, height trackViewHeight: CGFloat, zoom: CGFloat) -> CGPoint {
//        let trackWidth:  CGFloat = CGFloat(maxX - minX)
//        let trackHeight: CGFloat = CGFloat(maxY - minY)
//        let trackAspectRatio: CGFloat = trackWidth / trackHeight
//        let viewAspectRatio: CGFloat = width / height
//        let scale: CGFloat
//        if trackAspectRatio > viewAspectRatio {
//            scale = trackViewWidth / trackWidth
//        } else {
//            scale = trackViewHeight / trackHeight
//        }
//        let scaledX: CGFloat = CGFloat(x - minX) * scale
//        let scaledY: CGFloat = CGFloat(y - minY) * scale
//        return CGPoint(x: width * (1 - zoom) / 2 + zoom * scaledX, y: height * (1 - zoom) / 2 + zoom * scaledY)
//    }
    
    private func translateAllPoints(_ model: TrackModel) -> [CGPoint] {
        let trackViewWidth:  CGFloat = self.bounds.width
        let trackViewHeight: CGFloat = self.bounds.height
        
        var minX: CGFloat = 0
        var maxX: CGFloat = 0
        var minY: CGFloat = 0
        var maxY: CGFloat = 0
        
        var translatedPoints: [CGPoint] = []
        var centeredPoints: [CGPoint] = []
        
        for sector in model.sectors {
            minX = min(minX, CGFloat(min(sector[0], sector[2])))
            maxX = max(maxX, CGFloat(max(sector[0], sector[2])))
            minY = min(minY, CGFloat(min(sector[1], sector[3])))
            maxY = max(maxY, CGFloat(max(sector[1], sector[3])))
        }
        
        let trackWidth:  CGFloat = CGFloat(maxX - minX)
        let trackHeight: CGFloat = CGFloat(maxY - minY)
        let trackAspectRatio: CGFloat = trackWidth / trackHeight
        let viewAspectRatio: CGFloat = trackViewWidth / trackViewHeight
        let scale: CGFloat
        if trackAspectRatio > viewAspectRatio {
            scale = trackViewWidth / trackWidth
        } else {
            scale = trackViewHeight / trackHeight
        }
        
        var translatedMinX: CGFloat = 1e6
        var translatedMaxX: CGFloat = -1e6
        var translatedMinY: CGFloat = 1e6
        var translatedMaxY: CGFloat = -1e6
        
        for sector in model.sectors {

            let translatedX: CGFloat = zoom * (CGFloat(sector[0]) - minX) * scale
            let translatedY: CGFloat = zoom * (CGFloat(sector[1]) - minY) * scale
            
            translatedMinX = min(translatedMinX, translatedX)
            translatedMaxX = max(translatedMaxX, translatedX)
            translatedMinY = min(translatedMinY, translatedY)
            translatedMaxY = max(translatedMaxY, translatedY)
            
            translatedPoints.append(CGPoint(x: translatedX, y: translatedY))
        }
        
        for point in translatedPoints {
            //centering
            let centeredX: CGFloat = point.x + trackViewWidth  / 2 - (translatedMaxX - translatedMinX) / 2
            let centeredY: CGFloat = point.y + trackViewHeight / 2 - (translatedMaxY - translatedMinY) / 2
            centeredPoints.append(CGPoint(x: centeredX, y: centeredY))
        }
        
        return centeredPoints
    }
    
    private func drawBorders(_ model: TrackModel) {
        let translated: [CGPoint] = translateAllPoints(model)
        var minX: CGFloat = translated.first!.x
        var maxX: CGFloat = translated.first!.x
        var minY: CGFloat = translated.first!.y
        var maxY: CGFloat = translated.first!.y
        
        let trackViewWidth:  CGFloat = self.bounds.width
        let trackViewHeight: CGFloat = self.bounds.height
        
        for point in translated {
            minX = min(minX, point.x)
            maxX = max(maxX, point.x)
            minY = min(minY, point.y)
            maxY = max(maxY, point.y)
        }
        
        let box: CGRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        
        let boxLayer: CAShapeLayer = CAShapeLayer()
        boxLayer.path = UIBezierPath(rect: box).cgPath
        boxLayer.strokeColor = UIColor.systemPink.cgColor
        boxLayer.fillColor = UIColor.clear.cgColor

        shapeLayer.addSublayer(boxLayer)
        
        let box1: CGRect = CGRect(x: 0, y: 0, width: trackViewWidth - 10, height: trackViewHeight - 10)
        
        let boxLayer1: CAShapeLayer = CAShapeLayer()
        boxLayer1.path = UIBezierPath(rect: box1).cgPath
        boxLayer1.strokeColor = UIColor.systemMint.cgColor
        boxLayer1.fillColor = UIColor.clear.cgColor

        shapeLayer.addSublayer(boxLayer1)
        
        
        let radius: CGFloat = 7
        let ovalPath = UIBezierPath(ovalIn: CGRectMake((maxX - minX) / 2 + minX - radius, minY + (maxY - minY) / 2 - radius, 2 * radius, 2 * radius))
        let centerLayer = CAShapeLayer()
        centerLayer.path = ovalPath.cgPath
        centerLayer.fillColor = UIColor.systemPink.cgColor
        centerLayer.strokeColor = UIColor.systemMint.cgColor
        shapeLayer.addSublayer(centerLayer)
        
        let ovalPath1 = UIBezierPath(ovalIn: CGRectMake(trackViewWidth / 2 - radius, trackViewHeight / 2 - radius, 2 * radius, 2 * radius))
        let centerLayer1 = CAShapeLayer()
        centerLayer1.path = ovalPath1.cgPath
        centerLayer1.strokeColor = UIColor.systemPink.cgColor
        centerLayer1.fillColor = UIColor.systemMint.cgColor
        shapeLayer.addSublayer(centerLayer1)
    }
}

