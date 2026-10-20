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
    @Published var inventory: [InventoryItem] = [] {
        didSet {
            filter = ""
        }
    }
    
    @Published var matchingInventory: [InventoryItem] = []
    
    @Published var filter: String = "" {
        didSet {
            matchingInventory = inventory.filter { item in
                filter.isEmpty ||
                item.productName.lowercased().contains(filter.lowercased()) ||
                item.locationName.lowercased().contains(filter.lowercased())
            }.sorted { $0.productName < $1.productName }
        }
    } // added in more code for filtering -BB
    
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
            matchingInventory = inventory // Populates list initially on load - BB
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
