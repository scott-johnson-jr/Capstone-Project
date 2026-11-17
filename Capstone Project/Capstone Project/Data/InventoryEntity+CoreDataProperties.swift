//
//  InventoryEntity+CoreDataProperties.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//
//

public import Foundation
public import CoreData


public typealias InventoryEntityCoreDataPropertiesSet = NSSet

extension InventoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InventoryEntity> {
        return NSFetchRequest<InventoryEntity>(entityName: "InventoryEntity")
    }

    @NSManaged public var productId: Int64
    @NSManaged public var productName: String?
    @NSManaged public var productNumber: String?
    @NSManaged public var safetyStockLevel: Int64
    @NSManaged public var reorderPoint: Int64
    @NSManaged public var locationId: Int64
    @NSManaged public var locationName: String?
    @NSManaged public var shelf: String?
    @NSManaged public var bin: Int64
    @NSManaged public var quantity: Int64
    @NSManaged public var id: String?
    @NSManaged public var lastUpdated: Date?

}

extension InventoryEntity : Identifiable {

}
