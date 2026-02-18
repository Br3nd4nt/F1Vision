//
//  CarData.swift
//  F1Vision
//
//  Created by br3nd4nt on 03.02.2026.
//

import Foundation

struct CarData: Codable {
    let Entries: [Entry]
}

struct Entry: Codable {
    let Utc: String
    let Cars: [String: CarDataChannels]
}

struct CarDataChannels: Codable {
    let Channels: [String: Int]
    
    var RPM: Int? {
        return Channels["0"]
    }
    
    var speed: Int? {
        return Channels["2"]
    }
    
    var gear: Int? {
        return Channels["3"]
    }
    
    var throttle: Int? {
        return Channels["4"]
    }
    
    var brake: Int? {
        return Channels["5"]
    }
    
    var DRS: Int? {
        return Channels["45"]
    }
}
