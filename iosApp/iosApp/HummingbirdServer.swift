import Hummingbird
import HummingbirdFoundation
import CoreData

class HummingbirdServer {
    private let app: HBApplication

    init() {
        app = HBApplication()
        setupRoutes()
    }

    private func setupRoutes() {
        app.router.get("/users") { req -> [User] in
            return CoreDataStack.shared.fetchUsers()
        }

        app.router.post("/users") { req -> HTTPResponseStatus in
            let user = try req.decode(as: User.self)
            CoreDataStack.shared.saveUser(user: user)
            return .ok
        }

        // Additional routes for posts can be set up similarly
    }

    func start() {
        app.start()
    }

    func stop() {
        app.stop()
    }
}
