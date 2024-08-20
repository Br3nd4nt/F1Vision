//
//  SocketHelper.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.08.2024.
//

import SocketIO
// https://github.com/socketio/socket.io-client-swift
// https://www.youtube.com/watch?v=r_Ofc9saV60
import Foundation

final class SocketHelper: NSObject, ObservableObject {
    static private let host: String = "192.168.1.9"
    static private let port: UInt32 = 6969
    
    private var manager = SocketManager(socketURL: URL(string: "ws://\(host):\(port)")!, config: [.log(false), .compress])
    let socket: SocketIOClient
    
    private var message: String = ""
    
    @Published var trackLayoutPoints: [[Int]] = []
    
    override init() {
        self.socket = manager.defaultSocket
        super.init()
        socket.on(clientEvent: .connect){(data, ack) in
            print("Connected to: \(self.manager.socketURL.relativeString)")
            self.socket.emit("request_track_data", "request_track_data")
        }
        
        socket.on("track_data") {[weak self] (data, ack) in
            print("recieved smth")
                DispatchQueue.main.async {
                    self?.message = "\(data[0])"
                    
                    // parse json
                    self?.trackLayoutPoints = self?.parseJSON(rawData: self?.message ?? "") ?? []
                }
        }
        
        
    }
    
    func connect() {
        self.socket.connect()
        
    }
    
    func parseJSON(rawData: String) -> [[Int]] {
        if let data = rawData.data(using: .utf8) {
            print("trying to convert from JSON")
            let jsonData = try! JSONDecoder().decode([[Int]].self, from: data)
            print("Converted!")
            return jsonData
        }
        return []
    }
}


