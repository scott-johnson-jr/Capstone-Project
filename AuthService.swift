import Foundation

actor AuthService {
    static let shared = AuthService()
    
    private let baseURL = URL(string: "https://api.bootcampcentral.com")!
    private let session = URLSession.shared
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let encoder = JSONEncoder()
    
    private var currentTokens: LoginResults?
    
    // MARK: - Login
    func login(loginId: String, password: String) async throws -> LoginResults {
        let body = LoginRequest(loginId: loginId, password: password)
        let result = try await post(path: "/api/Login", body: body)
        currentTokens = result
        return result
    }
    
    // MARK: - Refresh
    func refresh() async throws -> LoginResults {
        guard let refreshToken = currentTokens?.refreshToken else {
            throw AuthError.missingRefreshToken
        }
        
        let body = RefreshTokenRequest(refreshToken: refreshToken)
        let result = try await post(path: "/api/Login/refresh", body: body)
        currentTokens = result
        return result
    }
    
    // MARK: - Get a valid access token (auto-refreshes if needed)
    func validAccessToken() async throws -> String {
        if let tokens = currentTokens,
           let expires = tokens.accessTokenExpiresAtUtc,
           expires > Date().addingTimeInterval(60),
           let token = tokens.accessToken {
            return token
        }
        
        let refreshed = try await refresh()
        guard let token = refreshed.accessToken else {
            throw AuthError.invalidResponse
        }
        return token
    }
    
    // MARK: - Private networking
    private func post<T: Encodable>(path: String, body: T) async throws -> LoginResults {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw AuthError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        
        return try decoder.decode(LoginResults.self, from: data)
    }
}

enum AuthError: Error, LocalizedError {
    case missingRefreshToken
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    
    var errorDescription: String? {
        switch self {
        case .missingRefreshToken: return "No refresh token available"
        case .invalidResponse: return "Invalid response from server"
        case .httpError(let code, _): return "HTTP error \(code)"
        }
    }
}
