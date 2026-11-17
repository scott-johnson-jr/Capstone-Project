//
//  InventoryRepository.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import Foundation
internal import CoreData

protocol InventoryRepositoryProtocol {
    func fetchInventory() async throws -> [InventoryItem]
}
final class InventoryRepository: InventoryRepositoryProtocol {
    private let apiClient: APIClient
    private let context: NSManagedObjectContext
    init(apiClient: APIClient,
         context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.apiClient = apiClient
        self.context = context
    }
    func fetchInventory() async throws -> [InventoryItem] {
        do {
            let inventory = try await apiClient.get(
                "/api/inventory",
                responseType: [InventoryItem].self
            )
            
            try await saveInventory(inventory)
            
            return inventory
        } catch {
            let savedInventory = try await fetchCachedInventory()
            
            if !savedInventory.isEmpty {
                return savedInventory
            }
            throw error
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
            
                guard let productName = entity.productName,
                      let productNumber = entity.productNumber,
                      let locationName = entity.locationName,
                      let shelf = entity.shelf else {
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
