//
//  AcronymsTests.swift
//  App
//
//  Created by NicoleYarroch on 7/14/19.
//

@testable import App

import Vapor
import XCTest
import FluentMySQL

final class AcronymsTests: XCTestCase {
    let acronymsShort = "TIL"
    let acronymsLong = "true in life"
    let acronymsURI = "/api/acronyms/"
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

    func testCreateAcronym() {
        let user = try! User.create(on: conn)
        let retreivedAcronym = try! Acronym.create(short: acronymsShort, long: acronymsLong, user: user, on: conn)
        
        XCTAssertEqual(retreivedAcronym.short, acronymsShort)
        XCTAssertEqual(retreivedAcronym.long, acronymsLong)
        XCTAssertEqual(retreivedAcronym.userID, user.id)
        XCTAssertNotNil(retreivedAcronym.id)
    }
    
    func testGetAcronyms() {
        let user1 = try! User.create(name: "Bill", username: "BillyFox76", on: conn)
        let user2 = try! User.create(name: "Jill", username: "JillyFox3", on: conn)
        let retreivedAcronym1 = try! Acronym.create(short: "BOB", long: "bring own beer", user: user1, on: conn)
        let retreivedAcronym2 = try! Acronym.create(short: "TIL", long: "true in life", user: user2, on: conn)
        
        let retrievedAcronyms = try! app.getResponse(to: acronymsURI, decodeTo: [Acronym].self)
        
        XCTAssertEqual(retrievedAcronyms.count, 2)
        // Acronym 1
        XCTAssertEqual(retrievedAcronyms[0].short, retreivedAcronym1.short)
        XCTAssertEqual(retrievedAcronyms[0].long, retreivedAcronym1.long)
        XCTAssertEqual(retrievedAcronyms[0].userID, user1.id)
        XCTAssertNotNil(retrievedAcronyms[0].id)
        // Acronym 2
        XCTAssertEqual(retrievedAcronyms[1].short, retreivedAcronym2.short)
        XCTAssertEqual(retrievedAcronyms[1].long, retreivedAcronym2.long)
        XCTAssertEqual(retrievedAcronyms[1].userID, user2.id)
        XCTAssertNotNil(retrievedAcronyms[1].id)
    }
    
    func testGetFirstAcronym() {
        let user1 = try! User.create(name: "Bill", username: "BillyFox76", on: conn)
        let user2 = try! User.create(name: "Jill", username: "JillyFox3", on: conn)
        let retreivedAcronym1 = try! Acronym.create(short: "BOB", long: "bring own beer", user: user1, on: conn)
        let _ = try! Acronym.create(short: "TIL", long: "true in life", user: user2, on: conn)

        let retrievedFirstAcronym = try! app.getResponse(to: "\(acronymsURI)/first", decodeTo: Acronym.self)

        XCTAssertEqual(retrievedFirstAcronym.short, retreivedAcronym1.short)
        XCTAssertEqual(retrievedFirstAcronym.long, retrievedFirstAcronym.long)
        XCTAssertEqual(retrievedFirstAcronym.userID, retreivedAcronym1.userID)
        XCTAssertNotNil(retrievedFirstAcronym.id)
    }
    
    func testGetAcronymWithID() {
        let user = try! User.create(on: conn)
        let retreivedAcronym = try! Acronym.create(short: acronymsShort, long: acronymsLong, user: user, on: conn)
        
        let retrievedAcronymWithID = try! app.getResponse(to: "\(acronymsURI)/\(retreivedAcronym.id!)", decodeTo: Acronym.self)

        XCTAssertEqual(retrievedAcronymWithID.short, acronymsShort)
        XCTAssertEqual(retrievedAcronymWithID.long, acronymsLong)
        XCTAssertEqual(retrievedAcronymWithID.userID, user.id)
        XCTAssertNotNil(retrievedAcronymWithID.id)
    }
    
    func testUpdateAcronym() {
        let user = try! User.create(on: conn)
        let initialAcronym = Acronym(short: "BOB", long: "Bring Own Beer", userID: user.id!)
        
        let retreivedAcronym = try! Acronym.create(short: initialAcronym.short, long: initialAcronym.long, user: user, on: conn)

        XCTAssertEqual(retreivedAcronym.short, initialAcronym.short)
        XCTAssertEqual(retreivedAcronym.long, initialAcronym.long)
        XCTAssertEqual(retreivedAcronym.userID, user.id)
        XCTAssertNotNil(retreivedAcronym.id)

        let updatedAcronym = initialAcronym
        updatedAcronym.short = "BOBed"
        updatedAcronym.long = "Big Or Bad"

        let retreivedUpdatedAcronym = try! app.getResponse(to: "\(acronymsURI)/\(retreivedAcronym.id!)", method: .PUT, headers: ["Content-Type": "application/json"], data: updatedAcronym, decodeTo: Acronym.self)

        XCTAssertEqual(retreivedUpdatedAcronym.short, updatedAcronym.short)
        XCTAssertEqual(retreivedUpdatedAcronym.long, updatedAcronym.long)
        XCTAssertEqual(retreivedUpdatedAcronym.userID, updatedAcronym.userID)
        XCTAssertNotNil(retreivedUpdatedAcronym.id)
    }
    
    func testDeletingAnAcronym() throws {
        let acronym = try Acronym.create(on: conn)
        var acronyms = try app.getResponse(to: acronymsURI, decodeTo: [Acronym].self)
        
        XCTAssertEqual(acronyms.count, 1)
        
        _ = try app.sendRequest(to: "\(acronymsURI)\(acronym.id!)", method: .DELETE)
        acronyms = try app.getResponse(to: acronymsURI, decodeTo: [Acronym].self)
        
        XCTAssertEqual(acronyms.count, 0)
    }

    func testDeleteAcronym() throws {
        let retreivedAcronym = try! Acronym.create(on: conn)
        let retrieveAcronyms = try! app.getResponse(to: acronymsURI, decodeTo: [Acronym].self)
        
        XCTAssertNotNil(retreivedAcronym)
        XCTAssertNotNil(retreivedAcronym.id)
        XCTAssertEqual(retrieveAcronyms.count, 1)

        let _ = try! app.sendRequest(to: "\(acronymsURI)/\(retreivedAcronym.id!)", method: .DELETE)
        let retrieveDeletedAcronyms = try! app.getResponse(to: acronymsURI, decodeTo: [Acronym].self)

        XCTAssertEqual(retrieveDeletedAcronyms.count, 0)
    }
    
    func testSearchShort() {
        let _ = try! Acronym.create(short: acronymsShort, long: acronymsLong, user: nil, on: conn)
        let searchResultShort = try! app.getResponse(to: "\(acronymsURI)/search?term=\(acronymsShort)", decodeTo: [Acronym].self)
        
        XCTAssertEqual(searchResultShort.count, 1)
        XCTAssertEqual(searchResultShort[0].short, acronymsShort)
        XCTAssertEqual(searchResultShort[0].long, acronymsLong)
        XCTAssertNotNil(searchResultShort[0].id)
    }
    
    func testSearchLong() {
        let _ = try! Acronym.create(short: acronymsShort, long: acronymsLong, user: nil, on: conn)
        let searchResultLong = try! app.getResponse(to: "\(acronymsURI)/search?term=\(AcronymsTests.splitString(string: acronymsLong))", decodeTo: [Acronym].self)
        
        XCTAssertEqual(searchResultLong.count, 1)
        XCTAssertEqual(searchResultLong[0].short, acronymsShort)
        XCTAssertEqual(searchResultLong[0].long, acronymsLong)
        XCTAssertNotNil(searchResultLong[0].id)
    }
    
    func testSorted() {
        let acronymA = try! Acronym.create(short: "Apple", long: "AAA", user: nil, on: conn)
        let acronymZ = try! Acronym.create(short: "Zebra", long: "Zebra cat", user: nil, on: conn)
        let acronymM = try! Acronym.create(short: "Moon", long: "Moon Time", user: nil, on: conn)
        
        let retrievedAcronyms = try! app.getResponse(to: acronymsURI, decodeTo: [Acronym].self)
        
        // Unsorted
        XCTAssertEqual(retrievedAcronyms.count, 3)
        XCTAssertEqual(retrievedAcronyms[0].short, acronymA.short)
        XCTAssertEqual(retrievedAcronyms[1].short, acronymZ.short)
        XCTAssertEqual(retrievedAcronyms[2].short, acronymM.short)
        
        // Sorted
        let retreivedSortedAcronyms = try! app.getResponse(to: "\(acronymsURI)/sorted", decodeTo: [Acronym].self)
        XCTAssertEqual(retreivedSortedAcronyms.count, 3)
        
        XCTAssertEqual(retreivedSortedAcronyms[0].short, acronymA.short)
        XCTAssertEqual(retreivedSortedAcronyms[1].short, acronymM.short)
        XCTAssertEqual(retreivedSortedAcronyms[2].short, acronymZ.short)
    }
    
    func testGetUser() {
        let user = try! User.create(name: "Winston", username: "teddybear", on: conn)
        let acronym = try! Acronym.create(short: acronymsShort, long: acronymsLong, user: user, on: conn)
        
        let acronymUser = try! app.getResponse(to: "\(acronymsURI)/\(acronym.id!)/user", decodeTo: User.self)
        
        XCTAssertEqual(acronymUser.name, "Winston")
        XCTAssertEqual(acronymUser.username, "teddybear")
        XCTAssertEqual(acronymUser.id, user.id)
    }
    
    func testGetCategory() {
        let category1 = try! Category.create(name: "Fun", on: conn)
        let category2 = try! Category.create(name: "Serious", on: conn)
        let acronym = try! Acronym.create(on: conn)
        
        let _ = try! app.sendRequest(to: "\(acronymsURI)/\(acronym.id!)/categories/\(category1.id!)", method: .POST)
        let _ = try! app.sendRequest(to: "\(acronymsURI)/\(acronym.id!)/categories/\(category2.id!)", method: .POST)
        
        let retreivedCategories = try! app.getResponse(to: "\(acronymsURI)/\(acronym.id!)/categories", decodeTo: [App.Category].self)
        
        XCTAssertEqual(retreivedCategories.count, 2)
        XCTAssertEqual(retreivedCategories[0].name, category1.name)
        XCTAssertEqual(retreivedCategories[1].name, category2.name)
    }
}

extension AcronymsTests {
    class func splitString(string: String) -> String {
        let splitString = string.components(separatedBy: " ")
        return splitString.joined(separator: "+")
    }
}
