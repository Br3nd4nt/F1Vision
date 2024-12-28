//
//  SocketDelegate.swift
//  F1Vision
//
//  Created by br3nd4nt on 20.08.2024.
//

import Foundation

protocol SocketDelegate: class{
    /**
    This method is called when StreamDelegate calls stream(_:eventCode:) with .hasBytesAvailable after all bytes have been read into a Data instance.
     - Parameter result: Data result from InputStream.
    */
    func socketDataReceived(result: Data?)
    
    /**
    Called when StreamDelegate calls stream(_:eventCode:) with .hasBytesAvailable after all bytes have been read into a Data instance and it was nil.
    */
    func receivedNil()
}
