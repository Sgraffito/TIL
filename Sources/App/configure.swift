import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentMySQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // If using localhost, the environment variables wil be `nil`
    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"
    let defaultPort = 3306
    let port = Environment.get("DATABASE_PORT") ?? "\(defaultPort)"
    let databaseConfig = MySQLDatabaseConfig(
        hostname: hostname,
        port: Int(port) ?? defaultPort,
        username: username,
        password: password,
        database: databaseName)
    let database = MySQLDatabase(config: databaseConfig)
    var databases = DatabasesConfig()
    databases.add(database: database, as: .mysql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Category.self, database: .mysql)
    // The model (i.e. Acronym must conform to the mySQLModel before this will work!
    migrations.add(model: User.self, database: .mysql)
    // Since there is a foreign key linking the Acronym table to the User table, the User table must be creted first
    migrations.add(model: Acronym.self, database: .mysql)
    migrations.add(model: AcronymCategoryPivot.self, database: .mysql)
    services.register(migrations)
    
    // Lets you revert and migrate a database
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
