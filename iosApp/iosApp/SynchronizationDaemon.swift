import Foundation
import CoreData
import UIKit

class SynchronizationDaemon {
    static let shared = SynchronizationDaemon()
    private let baseURL = "http://elixir-backend-url/api" // Elixir API URL authenticated via exchanged token using JWT
    
    private init() {}

    func synchronizeWithServer() {
        let context = CoreDataStack.shared.context
        
        // Fetch local data
        let users = CoreDataStack.shared.fetchUsers()
        let posts = CoreDataStack.shared.fetchPosts()
        
        // Convert to JSON
        let usersJSON = users.map { ["name": $0.name ?? "", "email": $0.email ?? ""] }
        let postsJSON = posts.map { ["user_id": $0.userId, "title": $0.title ?? "", "content": $0.content ?? ""] }
        
        // Synchronize users
        sendToServer(path: "/users", data: usersJSON) { result in
            switch result {
            case .success:
                print("Users synchronized successfully.")
            case .failure(let error):
                print("Failed to synchronize users: \(error)")
            }
        }
        
        // Synchronize posts
        sendToServer(path: "/posts", data: postsJSON) { result in
            switch result {
            case .success:
                print("Posts synchronized successfully.")
            case .failure(let error):
                print("Failed to synchronize posts: \(error)")
            }
        }
    }

    func performSyncOnRequest() {
        synchronizeWithServer()
    }

    private func sendToServer(path: String, data: [[String: Any]], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        task.resume()
    }
}
