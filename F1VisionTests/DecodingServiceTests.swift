//
//  DecodingServiceTests.swift
//  F1Vision
//
//  Created by br3nd4nt on 16.12.2025.
//

// swiftlint: disable all

import Testing
@testable import F1Vision
import Foundation

struct DecodingServiceTests {
    let service = DecodingService()
    
    @Test("Decodes and decompresses a zlib base64 encoded string")
    func testZlibDecoding() async throws {
        let dataString = "7ZZNa4NQEEX/y6w1vDfv++27bqEu2pQupGQhJaZEuxL/exV8xoBOievZBAQPzr1cDung5dJUbXWpIX50UFTnU9OW5x+IgAJ1LjEXvpAYjYkCDzZYEbw7QgZPdXutTg3EDuT489qW7e/wCM91cS2/vodX3iBq5TJ4h4jC6gyOEHNUoc9AP45IQTByZvCOIU6z0k6Mt3cMeZtfv81uM8FMiBYJMSPiqTh+NQ6SFWwwuINR24yUcx65zINEbfmwpQnC1Bu6EXIEpEK6TqbmUA2Q2tGCphKlHah5B+NnNBHIpQ5UWHZgzOPTscREN6ZjiTAbiKOKvpUm/LJoT5xmTGrNhVucvs/+l0gwVpiALBGWCEuEJbJHIuogB4mg9ywRlghLhCWyTyJKWiG0YYmwRFgiLJF9ErHOBB34nwhLhCXCElmTyGf/Bw=="
        let data = service.getBase64Decoded(dataString)
        #expect(data != nil, "Base64 decoding should not return nil")
        let decompressed = try service.inflate(data!)
        let json = try JSONSerialization.jsonObject(with: decompressed) as? [String: Any]
        #expect(json != nil, "Decoded JSON should be a dictionary")
    }
}
// swiftlint: enable all
