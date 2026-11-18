
import Foundation
import Combine

@MainActor
final class InventoryViewModel: ObservableObject {
    @Published var inventory: [InventoryItem] = [] {
        didSet { filter = "" }
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
    }

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isShowingCachedData = false

    private let repository: InventoryRepositoryProtocol

    init(repository: InventoryRepositoryProtocol) {
        self.repository = repository
    }

    func loadInventory() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            let result = try await repository.fetchInventory()

            inventory = result.items
            matchingInventory = result.items
            isShowingCachedData = result.isFromCache

            if result.isFromCache {
                errorMessage = "You're offline. Showing saved inventory. Pull to refresh or try again when connected."
            }
        } catch {
            errorMessage = "Unable to load inventory. Please check your connection and try again."
        }
    }
}

