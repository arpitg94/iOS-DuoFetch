import Foundation
import CoreData
import UIKit

class SynchronizationDaemon {
    static let shared = SynchronizationDaemon()
    
    private let baseURL = "http://elixir-backend-url/api" // Elixir API URL
    private var jwtToken: String? // JWT token managed securely

    private init() {
        // Load token from secure storage if available
        jwtToken = loadTokenFromStorage()
    }

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
        if let token = jwtToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: data, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }

            switch httpResponse.statusCode {
            case 200:
                completion(.success(()))
            case 401:
                // Handle token refresh logic here
                self?.refreshToken { result in
                    switch result {
                    case .success(let newToken):
                        // Retry the original request with the new token
                        self?.jwtToken = newToken
                        self?.saveTokenToStorage(newToken)
                        self?.sendToServer(path: path, data: data, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            default:
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Server returned status code \(httpResponse.statusCode)"])))
            }
        }
        task.resume()
    }

    private func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/refresh-token") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = jwtToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to refresh token"])))
                return
            }

            guard let data = data, 
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let newToken = json["token"] as? String else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])))
                return
            }

            completion(.success(newToken))
        }
        task.resume()
    }

    private func saveTokenToStorage(_ token: String) {
        // Save the token securely, e.g., using Keychain
        UserDefaults.standard.set(token, forKey: "jwtToken")
    }

    private func loadTokenFromStorage() -> String? {
        // Load the token securely, e.g., from Keychain
        return UserDefaults.standard.string(forKey: "jwtToken")
    }
}
