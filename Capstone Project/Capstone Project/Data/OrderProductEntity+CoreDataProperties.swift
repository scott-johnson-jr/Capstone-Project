//
//  OrderProductEntity+CoreDataProperties.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//
//

public import Foundation
public import CoreData


public typealias OrderProductEntityCoreDataPropertiesSet = NSSet

extension OrderProductEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OrderProductEntity> {
        return NSFetchRequest<OrderProductEntity>(entityName: "OrderProductEntity")
    }

    @NSManaged public var productId: Int64
    @NSManaged public var name: String?
    @NSManaged public var thumbnailPhoto: Data?
    @NSManaged public var thumbnailPhotoFileName: String?
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var orders: NSSet?

}

// MARK: Generated accessors for orders
extension OrderProductEntity {

    @objc(addOrdersObject:)
    @NSManaged public func addToOrders(_ value: OrderEntity)

    @objc(removeOrdersObject:)
    @NSManaged public func removeFromOrders(_ value: OrderEntity)

    @objc(addOrders:)
    @NSManaged public func addToOrders(_ values: NSSet)

    @objc(removeOrders:)
    @NSManaged public func removeFromOrders(_ values: NSSet)

}

extension OrderProductEntity : Identifiable {

}
