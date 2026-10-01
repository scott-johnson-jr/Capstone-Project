//
//  APIClient.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import Foundation
final class APIClient {
    private let baseURL = "https://api.bootcampcentral.com"
    func get<T: Decodable>(
        _ endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(
            string: baseURL + endpoint
        ) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )
        let (data, response) = try await URLSession.shared.data(
            for: request
        )
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        return try JSONDecoder().decode(
            T.self,
            from: data
        )
    }
}
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
}
