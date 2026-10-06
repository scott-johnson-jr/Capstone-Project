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
        // was running into errors and needed it implement additional code to identify -Blair
        if let rawJSON = String(data: data, encoding: .utf8) {
            print("Fetching URL: \(endpoint)")
            print("Raw Response: \(rawJSON)")
        }

        return try JSONDecoder().decode(
            T.self,
            from: data
        )
    }
    // MARK: - Dashboard Endpoints
    
    // removed "endpoint:" from funcs. Extraneous labels causing build errors and added square brackets for material requirements

    func fetchWeeklySales() async throws -> [WeeklySales] {
        return try await get("/api/Dashboard/weekly-sales", responseType: [WeeklySales].self)
    }

    func fetchBestWorstProducts() async throws -> [BestWorstProducts] {
        return try await get("/api/Dashboard/best-worst", responseType: [BestWorstProducts].self)
    }

    func fetchLowStock() async throws -> [LowStock] {
        return try await get("/api/Dashboard/low-stock", responseType: [LowStock].self)
    }

    func fetchShifts() async throws -> [Shifts] {
        return try await get("/api/Dashboard/shifts", responseType: [Shifts].self)
    }
    
}
enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
}
