//
//  RemoteRepositoryBase.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//

import Foundation
internal import CoreData

class RemoteRepositoryBase<Item: Codable> {
    
    var implicitContext: NSManagedObjectContext?
    
    init(authStatus: AuthStatus) {
    }
    
    
    // MARK: fetchAll method
    
    func fetchAll(_ urlString: String) async throws -> [Item] {
        
        let request = try createRequest(urlString)
        
        let data = try await executeRequest(request)
        
        do {
            let decoder = JSONDecoder()
            if let context = implicitContext {
                decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
            }
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([Item].self, from: data)
        }
        catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
        
    }
    // MARK: - fetchOne method
    func fetchOne(_ urlString: String) async throws -> Item {
        
        let request = try createRequest(urlString)

        
        let data = try await executeRequest(request)
        
        do {
            let decoder = JSONDecoder()
            if let context = implicitContext {
                decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
            }
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Item.self, from: data)
        }
        catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
        
        
    }
    // MARK: - post method
    func post(_ urlString: String, send item: Item) async throws -> Item {
        
        var request = try createRequest(urlString)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // ultimately we will add authorization to this request
        
        do {
            request.httpBody = try JSONEncoder().encode(item)
            
        }
        catch {
            throw NetworkError.encodingFailed(underlying: error)
        }
        
       let data = try await executeRequest(request)
        
        do {
            let decoder = JSONDecoder()
            if let context = implicitContext {
                decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
            }
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Item.self, from: data)
        }
        catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }
// MARK: - put method
    func put(_ urlString: String, send item: Item) async throws {
        
        var request = try createRequest(urlString)
        
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // ultimately we will add authorization to this request
        
        do {
            request.httpBody = try JSONEncoder().encode(item)
        }
        catch {
            throw NetworkError.encodingFailed(underlying: error)
        }
        
        let _ = try await executeRequest(request)
        
    }
    // MARK: - delete method
    func del(_ urlString: String) async throws {
     
        var request = try createRequest(urlString)
        request.httpMethod = "DELETE"
        
        let _ = try await executeRequest(request)
    }
    
    // MARK: - Private Utility methods
    
    private func createRequest(_ urlString: String) throws -> URLRequest {
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        return URLRequest(url: url)
    }
    // MARK: execute request
    private func executeRequest(_ request: URLRequest, isRetry: Bool = false) async throws -> Data {
        
        let token = try await currentAccessToken()
        
        // create a copy of the original request, as it is a let constant
        var authorizedRequest = request
        authorizedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: authorizedRequest)
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.badResponse(statusCode: -1)
        }
        
        guard (200...299).contains(http.statusCode) else {
            if http.statusCode == 401 {
                
                guard !isRetry else {
                    throw NetworkError.unauthorized
                }
                // try to refresh the auth token
                do {
                    try await AuthManager.shared.refreshSession()
                } catch is AuthError {
                    throw NetworkError.unauthorized
                }
                
                return try await executeRequest(request, isRetry: true)
            }
            throw NetworkError.badResponse(statusCode: http.statusCode)
        }
        
        return data
        
    }
    
    private func currentAccessToken() async throws -> String {
        do {
            return try await AuthManager.shared.validAccessToken()
        } catch is AuthError {
            throw NetworkError.unauthorized
        }
    }
    
}
