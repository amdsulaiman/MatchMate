//
//  NetworkManager.swift
//  MatchMate
//
//  Created by Mohammed.10824935 on 20/02/25.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchUsers(page: Int, resultsPerPage: Int = 10, completion: @escaping (Result<[User], Error>) -> Void) {
        let urlString = "https://randomuser.me/api/?page=\(page)&results=\(resultsPerPage)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                
                let decodedResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                completion(.success(decodedResponse.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL is invalid."
        case .noData: return "No data was returned from the server."
        }
    }
}
