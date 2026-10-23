import Foundation

struct LoginRequest: Codable {
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
