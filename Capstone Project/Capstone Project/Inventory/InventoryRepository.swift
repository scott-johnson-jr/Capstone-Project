
import Foundation
internal import CoreData

struct InventoryFetchResult {
    let items: [InventoryItem]
    let isFromCache: Bool
}

protocol InventoryRepositoryProtocol {
    func fetchInventory() async throws -> InventoryFetchResult
}

final class InventoryRepository: InventoryRepositoryProtocol {
    private let apiClient: any InventoryAPIProtocol
    private let context: NSManagedObjectContext

    init(
        apiClient: any InventoryAPIProtocol,
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        self.apiClient = apiClient
        self.context = context
    }

    func fetchInventory() async throws -> InventoryFetchResult {
        do {
            let inventory = try await apiClient.get(
                "/api/inventory",
                responseType: [InventoryItem].self
            )

            try await saveInventory(inventory)

            return InventoryFetchResult(
                items: inventory,
                isFromCache: false
            )
        } catch {
            let networkError = error

            do {
                let savedInventory = try await fetchCachedInventory()

                if !savedInventory.isEmpty {
                    return InventoryFetchResult(
                        items: savedInventory,
                        isFromCache: true
                    )
                }
            } catch {
                // Keep the original API error if reading the cache also fails.
            }

            throw networkError
        }
    }

    private func saveInventory(
        _ inventory: [InventoryItem]
    ) async throws {
        try await context.perform {
            for item in inventory {
                let request = InventoryEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "id == %@",
                    item.id
                )

                let entity = try self.context.fetch(request).first
                    ?? InventoryEntity(context: self.context)

                entity.id = item.id
                entity.productId = Int64(item.productId)
                entity.productName = item.productName
                entity.productNumber = item.productNumber
                entity.safetyStockLevel = Int64(item.safetyStockLevel)
                entity.reorderPoint = Int64(item.reorderPoint)
                entity.locationId = Int64(item.locationId)
                entity.locationName = item.locationName
                entity.shelf = item.shelf
                entity.bin = Int64(item.bin)
                entity.quantity = Int64(item.quantity)
                entity.lastUpdated = Date()
            }

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    private func fetchCachedInventory() async throws -> [InventoryItem] {
        try await context.perform {
            let request = InventoryEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "productName", ascending: true),
                NSSortDescriptor(key: "locationName", ascending: true)
            ]

            return try self.context.fetch(request).compactMap { entity in
                guard
                    let productName = entity.productName,
                    let productNumber = entity.productNumber,
                    let locationName = entity.locationName,
                    let shelf = entity.shelf
                else {
                    return nil
                }

                return InventoryItem(
                    productId: Int(entity.productId),
                    productName: productName,
                    productNumber: productNumber,
                    safetyStockLevel: Int(entity.safetyStockLevel),
                    reorderPoint: Int(entity.reorderPoint),
                    locationId: Int(entity.locationId),
                    locationName: locationName,
                    shelf: shelf,
                    bin: Int(entity.bin),
                    quantity: Int(entity.quantity)
                )
            }
        }
    }
}

