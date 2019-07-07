//
//  AcronymCategoryPivot.swift
//  App
//
//  Created by NicoleYarroch on 7/5/19.
//

import FluentMySQL
import Foundation

final class AcronymCategoryPivot: MySQLUUIDPivot, ModifiablePivot {
    var id: UUID?
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    typealias Left = Acronym
    typealias Right = Category
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID
    
    init(_ acronym: Acronym, _ category: Category) throws {
        self.acronymID = try acronym.requireID()
        self.categoryID = try category.requireID()
    }
}

//extension AcronymCategoryPivot: Migration {
//    static func prepare(on conn: MySQLConnection) -> Future<Void> {
//        return Database.create(self, on: conn) { builder in
//            try addProperties(to: builder)
//            builder.reference(from: \.acronymID, to: \Acronym.id, onDelete: .cascade)
//            builder.reference(from: \.categoryID, to: \Category.id, onDelete: .cascade)
//        }
//    }
//}

extension AcronymCategoryPivot: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            // use `.restrict` to throw a foreign key violation. `.cascade` will remove all mentions of the deleted entry from the table (or update)
            builder.reference(from: \.acronymID, to: \Acronym.id, onDelete: .cascade)
            builder.reference(from: \.categoryID, to: \Category.id, onDelete: .cascade)
        }
    }
}
