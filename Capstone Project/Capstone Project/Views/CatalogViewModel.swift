//
//  CatalogViewModel.swift
//  Capstone Project
//
//  Created by user301577 on 11/16/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class CatalogViewModel {
    enum State {
        case loading
        case loaded([Product])
        case failed(String)
    }

    private(set) var state: State = .loading

    func load(using repository: any RepositoryProtocol<Product>) async {
        if case .failed = state { state = .loading }
        do {
            state = .loaded(try await repository.getAll())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
