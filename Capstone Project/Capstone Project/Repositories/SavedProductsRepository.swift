
import Foundation
import CoreData

final class SavedProductsRepository {
    private let context: NSManagedObjectContext

    init(
        context: NSManagedObjectContext =
            PersistenceController.shared.container.viewContext
    ) {
        self.context = context
    }

    // Get all products saved by the user.
    func getSavedProducts() async throws -> [Product] {
        try await context.perform {
            let request = ProductEntity.fetchRequest()

            request.predicate = NSPredicate(
                format: "isSaved == YES"
            )

            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true)
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

    // Save or remove a product from saved products.
    func setSaved(
        _ isSaved: Bool,
        for product: Product
    ) async throws {
        try await context.perform {
            let request = ProductEntity.fetchRequest()

            request.predicate = NSPredicate(
                format: "productId == %lld",
                Int64(product.productId)
            )

            let entity: ProductEntity

            if let existingEntity = try self.context.fetch(request).first {
                entity = existingEntity
            } else if isSaved {
                entity = ProductEntity(context: self.context)
                entity.id = UUID()
                entity.productId = Int64(product.productId)
                entity.name = product.name
                entity.productNumber = product.productNumber
                entity.summary = product.summary
                entity.warranty = product.warranty?.value
                entity.color = product.color
                entity.price = NSDecimalNumber(
                    decimal: product.listPrice
                )
                entity.stockLevel = Int64(product.stockLevel)
            } else {
                return
            }

            entity.isSaved = isSaved

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    // Check whether a product is saved.
    func isSaved(productId: Int) async throws -> Bool {
        try await context.perform {
            let request = ProductEntity.fetchRequest()

            request.predicate = NSPredicate(
                format: "productId == %lld",
                Int64(productId)
            )

            return try self.context.fetch(request).first?.isSaved ?? false
        }
    }
}
