import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    let api = "api"
    let acronyms = "acronyms"
    let search = "search"
    let first = "first"
    let sorted = "sorted"

    func boot(router: Router) throws {
        let acronymsRoute = router.grouped(api, acronyms)
        
        acronymsRoute.post(Acronym.self, use: createHandler)
        acronymsRoute.get(use: getAllHandler)
        acronymsRoute.get(Acronym.parameter, use: getHandler)
        acronymsRoute.put(Acronym.parameter, use: updateHandler)
        acronymsRoute.delete(Acronym.parameter, use: deleteHandler)
        acronymsRoute.get(first, use: getFirstHandler)
        acronymsRoute.get(search, use: searchHandler)
        acronymsRoute.get(sorted, use: sortedHandler)
        acronymsRoute.get(Acronym.parameter, "user", use: getUserHandler)
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: request).all()
    }
    
    func getHandler(_ request: Request) throws -> Future<Acronym> {
        return try request.parameters.next(Acronym.self)
    }
    
    func getFirstHandler(_ request: Request) throws -> Future<Acronym> {
        return Acronym.query(on: request).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }
    
    func createHandler(_ request: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: request)
        
        // SAME AS
        
        //return try request
        //    .content
        //    .decode(Acronym.self)
        //    .flatMap(to: Acronym.self) { acronym in
        //        return acronym.save(on: request)
        //}

        // SAME AS

        //do {
        //    // Use Codeable to map the request's JSON to the Acronym model
        //    let decodedResult: Future<Acronym> = try request.content.decode(Acronym.self)
        //    // Extract the acronym once decoding is complete
        //    return decodedResult.flatMap(to: Acronym.self) { acronym in
        //        // Now that the Acronym object has been created, we can save it using the request database connection
        //        return acronym.save(on: request) // Saving the model returns a Future<Acronym>
        //    }
        //} catch {
        //    print("error decoding the request: \(request)")
        //    return request.future(Acronym(short: "default", long: "default"))
        //}
    }
    
    func updateHandler(_ request: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, request.parameters.next(Acronym.self), request.content.decode(Acronym.self)) { savedAcronym, updatedAcronym in
            savedAcronym.short = updatedAcronym.short
            savedAcronym.long = updatedAcronym.long
            savedAcronym.userID = updatedAcronym.userID
            return savedAcronym.save(on: request)
        }
    }
    
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(Acronym.self)
            .delete(on: request)
            .transform(to: HTTPStatus.noContent)
    }
    
    func searchHandler(_ request: Request) throws -> Future<[Acronym]> {
        let requestSearchTerm = request.query[String.self, at:"term"]
        guard let searchTerm = requestSearchTerm else {
            throw Abort(.badRequest)
        }
        
        // Search both "short" and "long"
        return Acronym.query(on: request).group(.or) { search in
            search.filter(\.short == searchTerm)
            search.filter(\.long == searchTerm)
        }.all()
    }
    
    func sortedHandler(_ request: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: request)
            .sort(\.short, .ascending)
            .all()
    }
    
    func getUserHandler(_ request: Request) throws -> Future<User> {
        return try request
            .parameters.next(Acronym.self)
            .flatMap(to: User.self) { acronym in
                return acronym.user.get(on: request)
        }
    }
}

