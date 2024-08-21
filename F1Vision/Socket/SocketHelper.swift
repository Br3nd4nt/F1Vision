//
//  TrackView.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.08.2024.
//

import Foundation
import UIKit

class SocketHelper: UIView {
    let textView: UILabel = UILabel()
    
    private let viewModel: TrackViewModel = TrackViewModel()
    
    private var bp = UIBezierPath()
    private let shapeLayer = CAShapeLayer()
    
    public var trackGP: String = ""
    
    private var minX: Int = 0
    private var maxX: Int = 0
    private var minY: Int = 0
    private var maxY: Int = 0
    
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    private let scale: CGFloat = 0.9
    
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
        width = self.bounds.width
        height = self.bounds.height
        
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
        viewModel.connect(completion: {model in
            print("got the model!")
            print("number of sectors: \(String(describing: model?.sectors.count))")
            
            // create the view
            if model!.sectors.count != 0 {
                self.configureTrack(model: model!)
            }
        })
        completion()
    }
    
    func drawDriver(driver: DriverData) {
        if trackGP.isEmpty {
            return
        }
        
        return
        let radius: CGFloat = 15
        let newCoords = self.translatePoint(x: Int(driver.coordinates.x), y: Int(driver.coordinates.y), minX: minX, maxX: maxX, minY: minY, maxY: maxY, width: width, height: height, scale: scale)
        
        var ovalPath = UIBezierPath(ovalIn: CGRectMake(newCoords.x + radius, newCoords.y + radius, 2 * radius, 2 * radius))
        
        let driverLayer: CAShapeLayer = CAShapeLayer()
        driverLayer.path = ovalPath.cgPath
        driverLayer.fillColor = UIColor.systemMint.cgColor
        driverLayer.strokeColor = UIColor.systemPink.cgColor
        
//        shapeLayer.addSublayer(driverLayer)
    }
    
    func configureTrack(model: TrackModel) {
        
        for sector in model.sectors {
            self.minX = min(self.minX, min(sector[0], sector[2]))
            self.maxX = max(self.maxX, max(sector[0], sector[2]))
            self.minY = min(self.minY, min(sector[1], sector[3]))
            self.maxY = max(self.maxY, max(sector[1], sector[3]))
        }
        
        bp.move(to: translatePoint(x: model.sectors[0][0], y: model.sectors[0][1], minX: self.minX, maxX: self.maxX, minY: self.minY, maxY: self.maxY, width: self.width, height: self.height, scale: self.scale))
        for sector in model.sectors {bp.addLine(to: translatePoint(x: sector[2], y: sector[3], minX: self.minX, maxX: self.maxX, minY: self.minY, maxY: self.maxY, width: self.width, height: self.height, scale: self.scale))}
        bp.addLine(to: translatePoint(x: model.sectors[0][0], y: model.sectors[0][1], minX: self.minX, maxX: self.maxX, minY: self.minY, maxY: self.maxY, width: self.width, height: self.height, scale: self.scale))
        
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.path = bp.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 20

        textView.isHidden = true
        shapeLayer.isHidden = false
        
        
    }
    
    func reset() {
        shapeLayer.isHidden = true
        textView.isHidden = false
        bp = UIBezierPath()
        self.trackGP = ""
        viewModel.trackGP = ""
        viewModel.trackSectors = TrackModel(sectors: [])
    }
    
    private func translatePoint(x: Int, y: Int, minX: Int, maxX: Int, minY: Int, maxY: Int, width: CGFloat, height: CGFloat, scale: CGFloat) -> CGPoint {
        let scaleValue: CGFloat = max(0, min(1, scale))
        let offset: CGFloat = (1 - scaleValue) / 2
        
        let translatedX: CGFloat = CGFloat(x - minX)
        let translatedY: CGFloat = CGFloat(y - minY)
        
        let pointX = (width * offset) + scaleValue * width * (translatedX / CGFloat(maxX - minX))
        let pointY = (height * offset) + scaleValue * height * (translatedY / CGFloat(maxY - minY))
        
        return CGPoint(x: pointX, y: pointY)
    }
    
    
}

