
public import Foundation
public import CoreData

public typealias ProductEntityCoreDataPropertiesSet = NSSet

extension ProductEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductEntity> {
        return NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var brand: String?
    @NSManaged public var categoryRaw: String?
    @NSManaged public var price: NSDecimalNumber?
    @NSManaged public var rating: Double
    @NSManaged public var reviewCount: Int64
    @NSManaged public var summary: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var specsData: Data?
    @NSManaged public var colors: String?
    @NSManaged public var symbol: String?
    @NSManaged public var accentRaw: String?
    @NSManaged public var lastUpdated: Date?

    // New API product attributes
    @NSManaged public var productId: Int64
    @NSManaged public var productNumber: String?
    @NSManaged public var warranty: String?
    @NSManaged public var color: String?
    @NSManaged public var stockLevel: Int64
    @NSManaged public var isSaved: Bool
    @NSManaged public var lastViewedAt: Date?
}

extension ProductEntity: Identifiable {
}

