//
//  JSONDataProtocol.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

protocol JSONDataProtocol {
    func loadJSON<T: Codable>(filename: String, as type: T.Type) -> T?
}
