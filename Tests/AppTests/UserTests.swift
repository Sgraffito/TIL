//
//  UserTests.swift
//  App
//
//  Created by NicoleYarroch on 7/8/19.
//

@testable import App

import Vapor
import XCTest
import FluentMySQL

final class UserTests: XCTestCase {
    let usersName = "Alice"
    let usersUsername = "AliceDog98"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: MySQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .mysql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    func testUserCanBeRetreivedFromAPI() throws {
        // Create a user using POST
        let user = User(name: usersName, username: usersUsername)
        let receivedUser = try app.getResponse(to: usersURI, method: .POST, headers: ["Content-Type": "application/json"], data: user, decodeTo: User.self)
        
        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)
        
        // Get all users using GET
        let users = try app.getResponse(to: usersURI, decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertNotNil(users[0].id)
    }
    
    func testGettingSingleUserFromAPI() throws {
        let user = try User.create(name: usersName, username: usersUsername, on: conn)
        
        XCTAssertEqual(user.name, usersName)
        XCTAssertEqual(user.username, usersUsername)
        XCTAssertNotNil(user.id)

        // Get the user using its id?
        let getUserURI = "\(usersURI)/\(user.id!)"
        let returnedUser = try app.getResponse(to: getUserURI, decodeTo: User.self)
        
        XCTAssertEqual(returnedUser.name, usersName)
        XCTAssertEqual(returnedUser.username, usersUsername)
        XCTAssertEqual(returnedUser.id, user.id)
    }
    
    func testGettingUsersAcronymsFromAPI() throws {
        let user = try User.create(on: conn)
        let acronym1 = try Acronym.create(short: "WOW", long: "World of War", user: user, on: conn)
        let acronym2 = try Acronym.create(short: "TIL", long: "True in Life", user: user, on: conn)
        
        let usersAcronyms = try app.getResponse(to: "\(usersURI)/\(user.id!)/acronyms", decodeTo: [Acronym].self)
        
        XCTAssertEqual(usersAcronyms.count, 2)
        // Acronym 1
        XCTAssertEqual(usersAcronyms[0].short, acronym1.short)
        XCTAssertEqual(usersAcronyms[0].long, acronym1.long)
        XCTAssertEqual(usersAcronyms[0].id, acronym1.id)
        XCTAssertEqual(usersAcronyms[0].userID, user.id)
        // Acronym 2
        XCTAssertEqual(usersAcronyms[1].short, acronym2.short)
        XCTAssertEqual(usersAcronyms[1].long, acronym2.long)
        XCTAssertEqual(usersAcronyms[1].id, acronym2.id)
        XCTAssertEqual(usersAcronyms[1].userID, user.id)
    }
}
