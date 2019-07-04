import Vapor
import Fluent


/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)

    let usersController = UsersController()
    try router.register(collection: usersController)


    // Basic "Hello, world!" example
    //    router.get("hello") { req in
    //        return "Hello, world!"
    //    }
    

//
//    router.get(api, acronyms, "sorted") { request -> Future<[Acronym]> in
//        return Acronym.query(on: request)
//            .sort(\.short, .ascending)
//            .all()
//    }
}
