//
//  TokenStore.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import Foundation

protocol TokenStore {
    func save(_ session: AuthSession) throws
    func load() throws -> AuthSession?
    func clear() throws
}
