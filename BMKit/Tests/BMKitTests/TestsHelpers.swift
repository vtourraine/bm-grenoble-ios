//
//  TestsHelpers.swift
//  BMKitTests
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import XCTest

extension XCTestCase {
    func data(filename: String) throws -> Data {
        let currentFileURL = URL(fileURLWithPath: #file)
        let directoryURL = currentFileURL.deletingLastPathComponent()
        let responseDataURL = directoryURL.appendingPathComponent(filename)
        let responseData = try Data(contentsOf: responseDataURL)
        return responseData
    }

    func decodeJSON<T>(_ type: T.Type, from filename: String) throws -> T where T : Decodable {
        let jsonData = try data(filename: filename)
        let decoder = JSONDecoder()
        let object = try decoder.decode(type, from: jsonData)
        return object
    }
}
