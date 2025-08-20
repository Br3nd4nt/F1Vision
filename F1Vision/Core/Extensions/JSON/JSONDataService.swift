//
//  JSONDataService.swift
//  F1Vision
//
//  Created by br3nd4nt on 21.08.2025.
//

import Foundation

class JSONDataService: JSONDataProtocol {

    static let shared = JSONDataService()

    private init() {}

    // MARK: - Generic JSON Parsing

    /// Load and parse a JSON file from the app bundle
    /// - Parameters:
    ///   - filename: Name of the JSON file (without extension)
    ///   - type: The type to decode the JSON into
    /// - Returns: Decoded object of the specified type
    func loadJSON<T: Codable>(filename: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ Could not find JSON file: \(filename).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let result = try decoder.decode(type, from: data)
            print("✅ Successfully loaded JSON: \(filename).json")
            return result
        } catch {
            print("❌ Error parsing JSON file \(filename).json: \(error)")
            return nil
        }
    }

    /// Load and parse a JSON file from a specific path
    /// - Parameters:
    ///   - path: Full path to the JSON file
    ///   - type: The type to decode the JSON into
    /// - Returns: Decoded object of the specified type
    func loadJSONFromPath<T: Codable>(path: String, as type: T.Type) -> T? {
        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let result = try decoder.decode(type, from: data)
            print("✅ Successfully loaded JSON from path: \(path)")
            return result
        } catch {
            print("❌ Error parsing JSON from path \(path): \(error)")
            return nil
        }
    }

    // MARK: - Utility Methods

    /// Check if a JSON file exists in the bundle
    func jsonFileExists(filename: String) -> Bool {
        return Bundle.main.url(forResource: filename, withExtension: "json") != nil
    }

    /// List all JSON files in the bundle
    func listJSONFiles() -> [String] {
        guard let resourcePath = Bundle.main.resourcePath else { return [] }

        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
            return files.filter { $0.hasSuffix(".json") }
        } catch {
            print("❌ Error listing JSON files: \(error)")
            return []
        }
    }
}
