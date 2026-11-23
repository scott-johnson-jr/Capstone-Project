
import Foundation

final class APIClient {
    private let baseURL = "https://api.bootcampcentral.com"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(
        _ endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) = try await session.data(for: request)

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

    // MARK: - Dashboard Endpoints

    func fetchWeeklySales() async throws -> [WeeklySales] {
        try await get(
            "/api/Dashboard/weekly-sales",
            responseType: [WeeklySales].self
        )
    }

    func fetchBestWorstProducts() async throws -> [BestWorstProducts] {
        try await get(
            "/api/Dashboard/best-worst",
            responseType: [BestWorstProducts].self
        )
    }

    func fetchLowStock() async throws -> [LowStock] {
        try await get(
            "/api/Dashboard/low-stock",
            responseType: [LowStock].self
        )
    }

    func fetchDepartments() async throws -> [Department] {
        try await get(
            "/api/Department",
            responseType: [Department].self
        )
    }

    func fetchShiftOptions() async throws -> [ShiftOption] {
        try await get(
            "/api/shift",
            responseType: [ShiftOption].self
        )
    }

    func fetchShifts() async throws -> [Shifts] {
        try await get(
            "/api/Dashboard/shifts",
            responseType: [Shifts].self
        )
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
}

