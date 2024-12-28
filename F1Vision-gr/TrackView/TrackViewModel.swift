//
//  TrackDataProvider.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.08.2024.
//

import SocketIO // MARK: try grpc??????
// https://github.com/socketio/socket.io-client-swift
// https://www.youtube.com/watch?v=r_Ofc9saV60
import Foundation

class TrackViewModel: ObservableObject {
//    static private let host: String = "192.168.1.9"
    static private let host: String = "127.0.0.1"
    static private let port: UInt32 = 6969
    
    static let trackDataKey: String = "track_data"
    private let defaults = UserDefaults.standard
    
    var trackSectors: TrackModel = TrackModel(sectors: [])
    var targetRatio: CGFloat = 0;
    
    private var manager = SocketManager(socketURL: URL(string: "ws://\(host):\(port)")!, config: [.log(false), .compress])
    let socket: SocketIOClient
    
    public var trackGP: String = ""
    
    init() {
        self.socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect){(data, ack) in
            print("Connected to: \(self.manager.socketURL.relativeString)")
            self.socket.emit("request_track_data", "\(self.targetRatio):\(self.trackGP)")
        }
        
        //MARK: track data recieved
        socket.on(TrackViewModel.trackDataKey) {[weak self] (data, ack) in
            print("recieved data")
            self?.trackSectors = self?.parseJSON(rawData: "\(data[0])") ?? TrackModel(sectors: [])
            if (self?.trackSectors != nil) {
//                self?.defaults.set(self?.trackSectors, forKey: TrackViewModel.trackDataKey)
                do {
                    let encoder = JSONEncoder()
                    let data = try encoder.encode(self?.trackSectors)
                    UserDefaults.standard.set(data, forKey: TrackViewModel.trackDataKey)
                } catch {
                    print("[Error] encoding to JSON")
                }
            }
            self?.socket.disconnect()
        }
    }
    
    func parseJSON(rawData: String) -> TrackModel {
        if let data = rawData.data(using: .utf8) {
            do {
                print("trying to convert from JSON")
                let jsonData = try JSONDecoder().decode([[Int]].self, from: data)
                print("Converted!")
                return TrackModel(sectors: jsonData)
            } catch {
                print()
                print("======")
                print("ERROR!")
                print("======")
                print()
                print("JSON is empty?")
                print("data:")
                print(data)
                print("raw data:")
                print(rawData)
                print("disconnecting the socket")
                self.socket.disconnect()
            }
        }
        return TrackModel(sectors: [])
    }
    
//    func connect(completion: @escaping (TrackModel?) -> Void) {
//        if !self.trackGP.isEmpty {
//            self.socket.connect()
//            self.socket.on(clientEvent: .disconnect) { data, ack in
//                completion(self.trackSectors) // ?????
//            }
//        }
//    }
    
    func connect(completion: @escaping () -> Void) {
        if !self.trackGP.isEmpty {
            self.socket.connect()
            self.socket.on(clientEvent: .disconnect) {_,_ in completion()}
        }
    }
}
