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
        
    }
    
    func connectToServer() {
        print("connection to socket")
        
        viewModel.connect(completion: {model in
            print("got the model!")
            print("number of sectors: \(String(describing: model?.sectors.count))")
            
            // create the view
            if model!.sectors.count != 0 {
                self.configureTrack(model: model!)
            }
        })
    }
    
    func configureTrack(model: TrackModel) {
        var minX: Int = 0
        var maxX: Int = 0
        var minY: Int = 0
        var maxY: Int = 0
        
        for sector in model.sectors {
            minX = min(minX, min(sector[0], sector[2]))
            maxX = max(maxX, max(sector[0], sector[2]))
            minY = min(minY, min(sector[1], sector[3]))
            maxY = max(maxY, max(sector[1], sector[3]))
        }
        
        let bp = UIBezierPath()
        bp.lineWidth = 10
//        bp.move(to: CGPoint(x:0, y:0))
//        bp.addLine(to: CGPoint(x:self.bounds.width, y:0))
//        bp.addLine(to: CGPoint(x:self.bounds.width, y: self.bounds.height))
        let width: CGFloat = self.bounds.width
        let height: CGFloat = self.bounds.height
        let scale: CGFloat = 0.9
        bp.move(to: translatePoint(x: model.sectors[0][0], y: model.sectors[0][1], minX: minX, maxX: maxX, minY: minY, maxY: maxY, width: width, height: height, scale: scale))
        for sector in model.sectors {
            bp.addLine(to: translatePoint(x: sector[2], y: sector[3], minX: minX, maxX: maxX, minY: minY, maxY: maxY, width: width, height: height, scale: scale))
        }
        bp.addLine(to: translatePoint(x: model.sectors[0][0], y: model.sectors[0][1], minX: minX, maxX: maxX, minY: minY, maxY: maxY, width: width, height: height, scale: scale))
//        bp.addLine(to: translatePoint(x: model.sectors.last![2], y: model.sectors.last![3], minX: minX, maxX: maxX, minY: minY, maxY: maxY, width: width, height: height, scale: scale))
            
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.path = bp.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.borderWidth = 10
        shapeLayer.lineWidth = 20
        self.layer.addSublayer(shapeLayer)
        textView.isHidden = true
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
