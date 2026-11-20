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
    case unauthorized
    case loginFailed
    case noRefreshToken
    case refreshFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .network(let error): return error.localizedDescription
        case .invalidResponse: return "Invalid response from server"
        case .unauthorized: return "Not authorized"
        case .loginFailed: return "Login failed. Check your credentials."
        case .noRefreshToken: return "No refresh token available"
        case .refreshFailed: return "Session expired. Please log in again."
        }
    }
}

extension Notification.Name {
    static let sessionExpired = Notification.Name("sessionExpired")
}

actor AuthManager {
    static let shared = AuthManager()

    private let baseURL = URL(string: "https://api.bootcampcentral.com")!
    private let store: TokenStore = KeychainTokenStore()
    private var currentTokens: LoginResults?
    private var refreshTask: Task<LoginResults, Error>?

    private init() {}

    func login(loginId: String, password: String) async throws -> LoginResults {
        let model = LoginModel(loginId: loginId, password: password)
        let results: LoginResults
        do {
            results = try await post(path: "/api/Login", body: model)
        } catch AuthError.unauthorized {
            throw AuthError.loginFailed
        }
        guard results.success, results.accessToken != nil else {
            throw AuthError.loginFailed
        }
        persist(results, fallbackUserName: loginId)
        currentTokens = results
        return results
    }

    func validAccessToken() async throws -> String {
        if currentTokens == nil {
            restoreSession()
        }
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

    func refreshSession() async throws {
        _ = try await refreshTokens()
    }

    func logout() {
        currentTokens = nil
        refreshTask?.cancel()
        refreshTask = nil
        try? store.clear()
    }

    private func expireSession() {
        currentTokens = nil
        try? store.clear()
        NotificationCenter.default.post(name: .sessionExpired, object: nil)
    }

    private func restoreSession() {
        guard let session = try? store.load(),
              session.refreshTokenExpiresAtUtc > Date() else { return }
        currentTokens = LoginResults(
            success: true,
            userName: session.userName,
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            accessTokenExpiresAtUtc: session.accessTokenExpiresAtUtc,
            refreshTokenExpiresAtUtc: session.refreshTokenExpiresAtUtc
        )
    }

    private func persist(_ results: LoginResults, fallbackUserName: String) {
        guard let access = results.accessToken,
              let refresh = results.refreshToken,
              let accessExpiry = results.accessTokenExpiresAtUtc,
              let refreshExpiry = results.refreshTokenExpiresAtUtc else { return }
        let session = AuthSession(
            userName: results.userName ?? fallbackUserName,
            accessToken: access,
            refreshToken: refresh,
            accessTokenExpiresAtUtc: accessExpiry,
            refreshTokenExpiresAtUtc: refreshExpiry
        )
        try? store.save(session)
    }

    private func refreshTokens() async throws -> LoginResults {
        if let refreshTask {
            return try await refreshTask.value
        }

        guard let refreshToken = currentTokens?.refreshToken else {
            throw AuthError.noRefreshToken
        }
        let expiredAccessToken = currentTokens?.accessToken

        let task = Task<LoginResults, Error> {
            defer { refreshTask = nil }
            let body = RefreshTokenRequest(refreshToken: refreshToken)
            let results: LoginResults
            do {
                results = try await post(
                    path: "/api/Login/refresh",
                    body: body,
                    bearer: expiredAccessToken
                )
            } catch AuthError.unauthorized {
                expireSession()
                throw AuthError.refreshFailed
            }
            guard results.success, results.accessToken != nil else {
                expireSession()
                throw AuthError.refreshFailed
            }
            persist(results, fallbackUserName: currentTokens?.userName ?? "")
            currentTokens = results
            return results
        }

        refreshTask = task
        return try await task.value
    }

    private func post<T: Encodable, R: Decodable>(
        path: String,
        body: T,
        bearer: String? = nil
    ) async throws -> R {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let bearer {
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        if [400, 401, 403].contains(http.statusCode) {
            throw AuthError.unauthorized
        }
        guard (200...299).contains(http.statusCode) else {
            throw AuthError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(R.self, from: data)
    }
}
