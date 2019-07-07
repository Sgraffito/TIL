//
//  CategoriesController.swift
//  App
//
//  Created by NicoleYarroch on 7/4/19.
//

import Vapor
import Fluent

struct CategoriesController: RouteCollection {
    func boot(router: Router) throws {
        let categoriesRoute = router.grouped("api", "categories")
        
        categoriesRoute.get(Category.parameter, use: getHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.post(Category.self, use: createHandler)
        categoriesRoute.get(Acronym.parameter, "acronyms", use: getAcronyms)
    }
    
    func getHandler(_ request: Request) throws -> Future<Category> {
        return try request.parameters.next(Category.self)
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[Category]> {
        return Category.query(on: request).all()
    }
    
    func createHandler(_ request: Request, category: Category) throws -> Future<Category> {
        return category.save(on: request)
    }
    
    func getAcronyms(_ request: Request) throws -> Future<[Acronym]> {
        return try request.parameters.next(Category.self).flatMap(to: [Acronym].self) { category in
            try category.acronyms.query(on: request).all()
        }
    }
}
