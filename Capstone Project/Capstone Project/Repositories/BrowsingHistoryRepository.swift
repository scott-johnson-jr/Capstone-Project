
import Foundation
import CoreData

final class BrowsingHistoryRepository {
    private let context: NSManagedObjectContext

    init(
        context: NSManagedObjectContext =
            PersistenceController.shared.container.viewContext
    ) {
        self.context = context
    }

    // Record when a product is viewed.
    func recordViewed(_ product: Product) async throws {
        try await context.perform {
            let request = ProductEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "productId == %lld",
                Int64(product.productId)
            )

            let entity: ProductEntity

            if let existing = try self.context.fetch(request).first {
                entity = existing
            } else {
                entity = ProductEntity(context: self.context)
                entity.id = UUID()
                entity.productId = Int64(product.productId)
                entity.isSaved = false
            }

            entity.name = product.name
            entity.productNumber = product.productNumber
            entity.summary = product.summary
            entity.warranty = product.warranty?.value
            entity.color = product.color
            entity.price = NSDecimalNumber(
                decimal: product.listPrice
            )
            entity.stockLevel = Int64(product.stockLevel)
            entity.lastViewedAt = Date()

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    // Retrieve recently viewed products, newest first.
    func getRecentlyViewed() async throws -> [Product] {
        try await context.perform {
            let request = ProductEntity.fetchRequest()

            request.predicate = NSPredicate(
                format: "lastViewedAt != nil"
            )

            request.sortDescriptors = [
                NSSortDescriptor(
                    key: "lastViewedAt",
                    ascending: false
                )
            ]

            let entities = try self.context.fetch(request)

            return entities.compactMap { entity in
                guard
                    let name = entity.name,
                    let productNumber = entity.productNumber,
                    let price = entity.price
                else {
                    return nil
                }

                return Product(
                    productId: Int(entity.productId),
                    name: name,
                    productNumber: productNumber,
                    summary: entity.summary,
                    warranty: entity.warranty.map {
                        FlexibleText($0)
                    },
                    color: entity.color,
                    listPrice: price.decimalValue,
                    stockLevel: Int(entity.stockLevel)
                )
            }
        }
    }
}

