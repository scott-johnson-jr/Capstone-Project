//
//  InventoryViewModel.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import Foundation
import Combine

@MainActor
final class InventoryViewModel: ObservableObject {
    @Published var inventory: [InventoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let repository: InventoryRepositoryProtocol
    init(repository: InventoryRepositoryProtocol) {
        self.repository = repository
    }
    func loadInventory() async {
        isLoading = true
        errorMessage = nil
        do {
            inventory = try await repository.fetchInventory()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
