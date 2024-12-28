//
//  DriverData.swift
//  F1Vision
//
//  Created by br3nd4nt on 10.06.2024.
//

import Foundation

struct DriverData {
    let number: Int;
    let dirverInitials: String;
    var tyreData: Int; //TODO: change later
    var position: Int;
    var time: Int;
    var deltaTime: Int;
    var coordinates: CGPoint
    
    func getPosition() -> String {
        return position.formatted() + "\t"
//        if position < 10 {
//            return " " + position.formatted()
//        } else {
//            return position.formatted()
//        }
    }
}
