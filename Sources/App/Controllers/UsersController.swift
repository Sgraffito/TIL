//
//  UsersController.swift
//  App
//
//  Created by NicoleYarroch on 7/3/19.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.post(User.self, use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(User.parameter, use: getHandler)
        usersRoute.get(User.parameter, "acronyms", use: getAcronyms)
    }
    
    func createHandler(_ request: Request, user: User) throws -> Future<User> {
        return user.save(on: request)
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[User]> {
        return User.query(on: request).all()
    }
    
    func getHandler(_ request: Request) throws -> Future<User> {
        return try request.parameters.next(User.self)
    }
    
    func getAcronyms(_ request: Request) throws -> Future<[Acronym]> {
        return try request
            .parameters.next(User.self)
            .flatMap(to: [Acronym].self) { user in
                try user.acronyms.query(on: request).all()
        }
    }
}
