//
//  AuthSession.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import Foundation

struct AuthSession: Codable {
    let userName: String
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiresAtUtc: Date
    let refreshTokenExpiresAtUtc: Date
}
