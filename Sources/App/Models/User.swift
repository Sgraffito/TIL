//
//  User.swift
//  App
//
//  Created by NicoleYarroch on 7/3/19.
//

import Foundation
import Vapor
import FluentMySQL

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    
    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
}

extension User: MySQLUUIDModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}
