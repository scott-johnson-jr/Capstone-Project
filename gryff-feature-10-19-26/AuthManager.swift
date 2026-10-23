import Foundation

struct LoginModel: Codable {
    let loginId: String
    let password: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct LoginResults: Codable {
    let success: Bool
    let userName: String?
    let accessToken: String?
    let refreshToken: String?
    let accessTokenExpiresAtUtc: Date?
    let refreshTokenExpiresAtUtc: Date?
}

enum AuthError: LocalizedError {
    case invalidURL
    case network(Error)
    case invalidResponse
    case loginFailed
    case noRefreshToken
    case refreshFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .network(let error): return error.localizedDescription
        case .invalidResponse: return "Invalid response from server"
        case .loginFailed: return "Login failed. Check your credentials."
        case .noRefreshToken: return "No refresh token available"
        case .refreshFailed: return "Session expired. Please log in again."
        }
    }
}

actor AuthManager {
    static let shared = AuthManager()

    private let baseURL = URL(string: "https://api.bootcampcentral.com")!
    private var currentTokens: LoginResults?
    private var refreshTask: Task<LoginResults, Error>?

    private init() {}

    func login(loginId: String, password: String) async throws -> LoginResults {
        let model = LoginModel(loginId: loginId, password: password)
        let results: LoginResults = try await post(path: "/api/Login", body: model)
        guard results.success, results.accessToken != nil else {
            throw AuthError.loginFailed
        }
        currentTokens = results
        return results
    }

    func validAccessToken() async throws -> String {
        if let tokens = currentTokens,
           let access = tokens.accessToken,
           let expires = tokens.accessTokenExpiresAtUtc,
           expires > Date().addingTimeInterval(30) {
            return access
        }
        let refreshed = try await refreshTokens()
        guard let access = refreshed.accessToken else {
            throw AuthError.refreshFailed
        }
        return access
    }

    func logout() {
        currentTokens = nil
        refreshTask?.cancel()
        refreshTask = nil
    }

    private func refreshTokens() async throws -> LoginResults {
        if let refreshTask {
            return try await refreshTask.value
        }

        guard let refreshToken = currentTokens?.refreshToken else {
            throw AuthError.noRefreshToken
        }

        let task = Task<LoginResults, Error> {
            defer { refreshTask = nil }
            let body = RefreshTokenRequest(refreshToken: refreshToken)
            let results: LoginResults = try await post(path: "/api/Login/refresh", body: body)
            guard results.success, results.accessToken != nil else {
                throw AuthError.refreshFailed
            }
            currentTokens = results
            return results
        }

        refreshTask = task
        return try await task.value
    }

    private func post<T: Encodable, R: Decodable>(path: String, body: T) async throws -> R {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw AuthError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(R.self, from: data)
    }
}
