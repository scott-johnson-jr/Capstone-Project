//
//  AuthStatus.swift
//  Capstone Project
//
//  Created by user301577 on 9/28/26.
//

import SwiftUI
import Combine

class AuthStatus: ObservableObject {

    @Published private(set) var isLoggedIn = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        if let session = try? KeychainTokenStore().load(),
           session.refreshTokenExpiresAtUtc > Date() {
            isLoggedIn = true
        }

        NotificationCenter.default.publisher(for: .sessionExpired)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.setLoggedIn(false)
            }
            .store(in: &cancellables)
    }

    func setLoggedIn(_ value: Bool) {
        withAnimation {
            isLoggedIn = value
        }
    }
}
