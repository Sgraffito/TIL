import Vapor
//imprt FluentSQLite÷
import FluentMySQL

final class Acronym: Codable {
    var id: Int? // conforms to the SQLiteModel protocol
    var userID: User.ID
    var short: String
    var long: String
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
    
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()
    }
}

// The table where the Model is saved
extension Acronym: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

// Model
// SQLiteModel same as:
//    typealias Database = SQLiteDatabase
//    typealias ID = Int
//    public static var idKey: IDKey = \Acronym.id
extension Acronym: MySQLModel {}

// Allows you to save the Model
extension Acronym: Content {}

// Extends type saftey to the Model
extension Acronym: Parameter {}
