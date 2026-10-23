//
//  RemoteOrderRepository.swift
//  Capstone Project
//
//  Created by user301577 on 10/6/26.
//


import Foundation
internal import CoreData

class RemoteOrderRepositoryDirectory: RepositoryProtocol {

    private let urlBase: String
    private let context: NSManagedObjectContext

    init(urlBase: String,
         context: NSManagedObjectContext =
         PersistenceController.shared.container.viewContext) {
        self.urlBase = urlBase
        self.context = context
    }

    func getAll() async throws -> [Order] {
        do {
            let urlString = "\(urlBase)/Order/Customer/"
            let orders = try await fetchAll(urlString)
            try await saveOrder(orders)
            return orders
        } catch {
            let savedOrders = try await fetchCachedOrders()

            if !savedOrders.isEmpty {
                return savedOrders
            }

            throw error
        }
    }

    func getById(_ orderId: Order.ID) async throws -> Order? {
        let urlString = "\(urlBase)/Order/Customer/\(orderId)"

        do {
            let order = try await fetchOne(urlString)

            if let order = order {
                try await saveOrder([order])
            }

            return order
        } catch {
            return try await fetchCachedOrder(byId: orderId)
        }
    }
    
    private func fetchAll(_ urlString: String) async throws -> [Order] {
        let data = try await fetchData(urlString)
        return try decoder.decode([Order].self, from: data)
    }

    private func fetchOne(_ urlString: String) async throws -> Order? {
        let data = try await fetchData(urlString)
        return try decoder.decode(Order.self, from: data)
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
    
    private func saveOrder(_ orders: [Order]) async throws {
        try await context.perform {
            for order in orders {
                let request = OrderEntity.fetchRequest()
                
                request.predicate = NSPredicate(
                    format: "id == %@",
                    NSNumber(value: order.id)
                )

                let entity = try self.context.fetch(request).first
                    ?? OrderEntity(context: self.context)

                entity.id = Int64(order.id)
                entity.customerId = Int64(order.customerId)
                entity.firstName = order.firstName
                entity.lastName = order.lastName
                entity.suffix = order.suffix
                entity.orderDate = order.orderDate
                entity.shipDate = order.shipDate
                entity.productName = order.productName
                entity.orderNumber = Int64(order.orderNumber)
                entity.orderQty = Int64(order.orderQty)
                entity.unitPrice = order.unitPrice
                entity.lineTotal = order.lineTotal
            }

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    
    private func fetchCachedOrders() async throws -> [Order] {
        try await context.perform {
            let request = OrderEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "orderDate", ascending: false)
            ]

            return try self.context.fetch(request).compactMap { entity in
                guard
                    let firstName = entity.firstName,
                    let lastName = entity.lastName,
                    let orderDate = entity.orderDate,
                    let shipDate = entity.shipDate,
                    let productName = entity.productName
                else {
                    return nil
                }

                return Order(
                    id: Int(entity.id),
                    customerId: Int(entity.customerId),
                    firstName: firstName,
                    lastName: lastName,
                    suffix: entity.suffix,
                    orderDate: orderDate,
                    shipDate: shipDate,
                    productName: productName,
                    orderNumber: Int(entity.orderNumber),
                    orderQty: Int(entity.orderQty),
                    unitPrice: entity.unitPrice,
                    lineTotal: entity.lineTotal
                )
            }
        }
    }

    private func fetchCachedOrder(byId orderId: Order.ID) async throws -> Order? {
        try await context.perform {
            let request = OrderEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "id == %lld",
                Int64(orderId)
            )
            request.fetchLimit = 1

            guard
                let entity = try self.context.fetch(request).first,
                let firstName = entity.firstName,
                let lastName = entity.lastName,
                let orderDate = entity.orderDate,
                let shipDate = entity.shipDate,
                let productName = entity.productName
            else {
                return nil
            }

            return Order(
                id: Int(entity.id),
                customerId: Int(entity.customerId),
                firstName: firstName,
                lastName: lastName,
                suffix: entity.suffix,
                orderDate: orderDate,
                shipDate: shipDate,
                productName: productName,
                orderNumber: Int(entity.orderNumber),
                orderQty: Int(entity.orderQty),
                unitPrice: entity.unitPrice,
                lineTotal: entity.lineTotal
            )
        }
    }

        private var decoder: JSONDecoder {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(formatter)
            return decoder
        }
    }
