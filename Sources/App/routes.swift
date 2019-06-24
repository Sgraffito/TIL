import Vapor
import Fluent


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let api = "api"
    let acronyms = "acronyms"
    
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // GET all
    router.get(api, acronyms) { request -> Future<[Acronym]> in
        return Acronym.query(on: request).all()
    }

    // Post /api/acronyms/<ID>
    router.get(api, acronyms, Acronym.parameter) { request -> Future<Acronym> in
        // handles errors if wrong type is passed
        return try request.parameters.next(Acronym.self)
    }
    
    router.post("api", "acronyms") { request -> Future<Acronym> in
        do {
            // Use Codeable to map the request's JSON to the Acronym model
            let decodedResult: Future<Acronym> = try request.content.decode(Acronym.self)
            // Extract the acronym once decoding is complete
            return decodedResult.flatMap(to: Acronym.self) { acronym in
                // Now that the Acronym object has been created, we can save it using the request database connection
                return acronym.save(on: request) // Saving the model returns a Future<Acronym>
            }
        } catch {
            print("error decoding the request: \(request)")
            return request.future(Acronym(short: "default", long: "default"))
        }
        
        // Same as
        //        return try request.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
        //            return acronym.save(on: request) // Saving the model returns a Future<Acronym>
        //        }

    }
    
    router.put(api, acronyms, Acronym.parameter) { request -> Future<Acronym> in
        return try flatMap(to: Acronym.self,
                           // Searches database for ID passed in /api/acronyms/<ID>
                           request.parameters.next(Acronym.self),
                           // Use Codeable to map the request's JSON to the Acronym model
                           request.content.decode(Acronym.self))
        { acronym, updatedAcronym in
            // Update the acronym and save it to the database
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
            return acronym.save(on: request)
        }
    }
    
    router.delete(api, acronyms, Acronym.parameter) { request -> Future<HTTPStatus> in
            return try request.parameters.next(Acronym.self)
                .delete(on: request)
                .transform(to: HTTPStatus.noContent)
    }
    
    router.get(api, acronyms, "search") { request -> Future<[Acronym]> in
        let requestSearchTerm = request.query[String.self, at:"term"]
        guard let searchTerm = requestSearchTerm else { throw Abort(.badRequest) }
        
        // only search "short"
        //        return Acronym.query(on: request)
        //            .filter(\.short == searchTerm)
        //            .all()
        
        // Search both "short" and "long"
        return Acronym.query(on: request).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
    }
    
    router.get(api, acronyms, "first") { request -> Future<Acronym> in
        return Acronym.query(on: request).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }
    
    router.get(api, acronyms, "sorted") { request -> Future<[Acronym]> in
        return Acronym.query(on: request)
            .sort(\.short, .ascending)
            .all()
    }
}
