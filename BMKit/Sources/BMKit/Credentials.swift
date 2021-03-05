//
//  Credentials.swift
//  BMKit
//
//  Created by Vincent Tourraine on 13/03/2020.
//

import Foundation

public struct Credentials: Codable {
    public let token: String
    public let settingsToken: String
    public let userIdentifier: String
}
