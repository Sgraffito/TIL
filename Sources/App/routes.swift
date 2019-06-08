import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Post
    router.post("api", "acronyms") { request -> Future<Acronym> in
        do {
            // Use Codeable to map the request's JSON to the Acronym model
            let decodedResult: Future<Acronym> = try request.content.decode(Acronym.self)
            // Extract the acronym once decoding is complete
            return decodedResult.flatMap(to: Acronym.self) { acronym  in
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
}
