//
//  User.swift
//  MatchMate
//
//  Created by Mohammed.10824935 on 20/02/25.
//

import Foundation

struct UserResponse: Codable {
    let results: [User]
}

struct User: Codable {
    let id = UUID()
    let name: Name
    let picture: Picture
    let dob: DOB
    let location: Location

    struct Name: Codable {
        let first: String
        let last: String
    }

    struct Picture: Codable {
        let large: String
    }

    struct DOB: Codable {
        let age: Int
    }

    struct Location: Codable {
        let city: String
        let state: String
        let country: String
    }
}
