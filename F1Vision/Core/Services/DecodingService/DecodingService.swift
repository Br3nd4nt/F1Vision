//
//  DecodingService.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

import Compression
import Foundation

final class DecodingService {
    func getBase64Decoded(_ text: String) -> Data? {
        Data(base64Encoded: text)
    }
    
    func inflate(_ input: Data) throws -> Data {
        var index = 0
        let bufferSize = input.count
        
        var inputFilter = try InputFilter(.decompress, using: .zlib) { (length: Int) -> Data? in
            let rangeLength = min(length, bufferSize - index)
            let subdata = input.subdata(in: index ..< index + rangeLength)
            index += rangeLength
            
            return subdata
        }
        
        var output = Data()
        let pageSize = 8 // ???
        
        while let page = try inputFilter.readData(ofLength: pageSize) {
            output.append(page)
        }
        return output
    }
}
