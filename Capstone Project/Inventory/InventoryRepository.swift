//
//  InventoryRepository.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import Foundation
protocol InventoryRepositoryProtocol {
    func fetchInventory() async throws -> [InventoryItem]
}
final class InventoryRepository: InventoryRepositoryProtocol {
    private let apiClient: APIClient
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    func fetchInventory() async throws -> [InventoryItem] {
        try await apiClient.get(
            "/api/inventory",
            responseType: [InventoryItem].self
        )
    }
}
