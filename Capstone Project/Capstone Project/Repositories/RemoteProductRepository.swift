
import Foundation
import CoreData

final class RemoteProductRepository: RepositoryProtocol {
    private let urlBase: String
    private let context: NSManagedObjectContext

    init(
        urlBase: String,
        context: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        self.urlBase = urlBase
        self.context = context
    }

    func getAll() async throws -> [Product] {
        do {
            let data = try await fetchData("\(baseURL)/Product")
            let products = try decoder.decode([Product].self, from: data)

            try await saveProducts(products)

            return products
        } catch {
            let originalError = error

            do {
                let savedProducts = try await fetchCachedProducts()

                if !savedProducts.isEmpty {
                    return savedProducts
                }
            } catch {
                // Preserve the original API error if cache reading fails.
            }

            throw originalError
        }
    }

    func getById(_ productId: Product.ID) async throws -> Product? {
        let data = try await fetchData("\(baseURL)/Product/\(productId)")

        let product = try decoder.decode(Product.self, from: data)

        try await saveProducts([product])

        return product
    }

    private var baseURL: String {
        urlBase.hasSuffix("/")
            ? String(urlBase.dropLast())
            : urlBase
    }

    private func saveProducts(_ products: [Product]) async throws {
        try await context.perform {
            for product in products {
                let request = ProductEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "productId == %lld",
                    Int64(product.productId)
                )

                let entity = try self.context.fetch(request).first
                    ?? ProductEntity(context: self.context)

                entity.id = entity.id ?? UUID()
                entity.productId = Int64(product.productId)
                entity.name = product.name
                entity.productNumber = product.productNumber
                entity.summary = product.summary
                entity.warranty = product.warranty?.value
                entity.color = product.color
                entity.price = NSDecimalNumber(decimal: product.listPrice)
                entity.stockLevel = Int64(product.stockLevel)
                entity.lastUpdated = Date()
            }

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    private func fetchCachedProducts() async throws -> [Product] {
        try await context.perform {
            let request = ProductEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true)
            ]

            return try self.context.fetch(request).compactMap { entity in
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
                    warranty: entity.warranty.map { FlexibleText($0) },
                    color: entity.color,
                    listPrice: price.decimalValue,
                    stockLevel: Int(entity.stockLevel)
                )
            }
        }
    }

    private func fetchData(_ urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard
            let http = response as? HTTPURLResponse,
            (200..<300).contains(http.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return data
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

