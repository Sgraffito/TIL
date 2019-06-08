import Vapor
import FluentSQLite

final class Acronym: Codable {
    var id: Int? // conforms to the SQLiteModel protocol
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

// Model
// SQLiteModel same as:
//    typealias Database = SQLiteDatabase
//    typealias ID = Int
//    public static var idKey: IDKey = \Acronym.id
extension Acronym: SQLiteModel {}

// The table where the Model is saved
extension Acronym: Migration {}

// Allows you to save the Model
extension Acronym: Content {}