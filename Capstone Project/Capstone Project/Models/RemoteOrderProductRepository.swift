//
//  RemoteProductRepository.swift
//  Capstone Project
//
//  Created by user301577 on 10/12/26.
//

import Foundation
internal import CoreData
// remote repository for the images in the orderdetails app
class RemoteOrderProductRepository: RepositoryProtocol {

    private let urlBase: String
    private let context: NSManagedObjectContext

    init(urlBase: String,
         context: NSManagedObjectContext =
    PersistenceController.shared.container.viewContext) {
        self.urlBase = urlBase
        self.context = context
    }

    func getAll() async throws -> [OrderProduct] {
        do {
            let data = try await fetchData("\(urlBase)/Product")
            let orderProducts = try JSONDecoder().decode([OrderProduct].self, from: data)
            
            try await saveOrderProducts(orderProducts)
            
            return orderProducts
        } catch {
            let savedOrderProducts = try await fetchCachedOrderProducts()
            
            if !savedOrderProducts.isEmpty {
                return savedOrderProducts
            }
            throw error
        }
    }

    func getById(_ orderProductId: OrderProduct.ID) async throws -> OrderProduct? {
        let urlString = "\(urlBase)/Product"
        return try await fetchOne(urlString)
    }


    private func fetchAll(_ urlString: String) async throws -> [OrderProduct] {
        let data = try await fetchData(urlString)
        return try JSONDecoder().decode([OrderProduct].self, from: data)
    }

    private func fetchOne(_ urlString: String) async throws -> OrderProduct? {
        let data = try await fetchData(urlString)
        return try JSONDecoder().decode(OrderProduct.self, from: data)
    }

    private func fetchData(_ urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
                
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    private func saveOrderProducts(_ orderProducts: [OrderProduct]) async throws {
        try await context.perform {
            for orderProduct in orderProducts {
                let request = OrderProductEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "productId == %@",
                    NSNumber(value: orderProduct.productId)
                )

                let entity = try self.context.fetch(request).first
                    ?? OrderProductEntity(context: self.context)

                entity.productId = Int64(orderProduct.productId)
                entity.name = orderProduct.name
                entity.thumbnailPhoto = orderProduct.thumbnailPhoto
                entity.thumbnailPhotoFileName = orderProduct.thumbnailPhotoFileName
                entity.lastUpdated = Date()
            }

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    private func fetchCachedOrderProducts() async throws -> [OrderProduct] {
        try await context.perform {
            let request = OrderProductEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true)
            ]

            return try self.context.fetch(request).compactMap { entity in
                guard let name = entity.name else {
                    return nil
                }

                return OrderProduct(
                    productId: Int(entity.productId),
                    name: name,
                    thumbnailPhoto: entity.thumbnailPhoto,
                    thumbnailPhotoFileName: entity.thumbnailPhotoFileName
                )
            }
        }
    }
    
}
