
import Foundation
import CoreData
import Testing
@testable import Capstone_Project

@MainActor
struct InventoryRepositoryTests {

    @Test func cachedInventoryIsReturnedWhenAPIFails() async throws {
        let context = try await makeContext()
        let api = MockInventoryAPI(shouldFail: true)

        let entity = InventoryEntity(context: context)
        entity.id = "test-item"
        entity.productId = 1
        entity.productName = "Test Product"
        entity.productNumber = "TEST-001"
        entity.safetyStockLevel = 10
        entity.reorderPoint = 5
        entity.locationId = 1
        entity.locationName = "Main Warehouse"
        entity.shelf = "A"
        entity.bin = 1
        entity.quantity = 20

        try context.save()

        let repository = InventoryRepository(
            apiClient: api,
            context: context
        )

        let result = try await repository.fetchInventory()

        #expect(result.isFromCache)
        #expect(result.items.count == 1)
        #expect(result.items.first?.productName == "Test Product")
    }

    @Test func apiFailureWithoutCacheThrowsError() async throws {
        let context = try await makeContext()
        let api = MockInventoryAPI(shouldFail: true)

        let repository = InventoryRepository(
            apiClient: api,
            context: context
        )

        do {
            _ = try await repository.fetchInventory()
            Issue.record("Expected API failure")
        } catch {
            #expect(error is URLError)
        }
    }

    private func makeContext() async throws -> NSManagedObjectContext {
        let model = PersistenceController.shared.container.managedObjectModel

        let container = NSPersistentContainer(
            name: "TestContainer",
            managedObjectModel: model
        )

        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in

            container.loadPersistentStores { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }

        return container.viewContext
    }
}

private struct MockInventoryAPI: InventoryAPIProtocol {
    let shouldFail: Bool

    func get<T: Decodable>(
        _ endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        if shouldFail {
            throw URLError(.notConnectedToInternet)
        }

        return [] as! T
    }
}
