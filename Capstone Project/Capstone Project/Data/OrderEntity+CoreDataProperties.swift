//
//  OrderEntity+CoreDataProperties.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//
//

public import Foundation
public import CoreData


public typealias OrderEntityCoreDataPropertiesSet = NSSet

extension OrderEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderEntity> {
        return NSFetchRequest<OrderEntity>(entityName: "OrderEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var customerId: Int64
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var suffix: String?
    @NSManaged public var orderDate: Date?
    @NSManaged public var shipDate: Date?
    @NSManaged public var productName: String?
    @NSManaged public var orderNumber: Int64
    @NSManaged public var orderQty: Int64
    @NSManaged public var unitPrice: Double
    @NSManaged public var lineTotal: Double
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var products: NSSet?

}

// MARK: Generated accessors for products
extension OrderEntity {

    @objc(addProductsObject:)
    @NSManaged public func addToProducts(_ value: OrderProductEntity)

    @objc(removeProductsObject:)
    @NSManaged public func removeFromProducts(_ value: OrderProductEntity)

    @objc(addProducts:)
    @NSManaged public func addToProducts(_ values: NSSet)

    @objc(removeProducts:)
    @NSManaged public func removeFromProducts(_ values: NSSet)

}

extension OrderEntity : Identifiable {

}
