//
//  EmployeeEntity+CoreDataProperties.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//
//

public import Foundation
public import CoreData


public typealias EmployeeEntityCoreDataPropertiesSet = NSSet

extension EmployeeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmployeeEntity> {
        return NSFetchRequest<EmployeeEntity>(entityName: "EmployeeEntity")
    }

    @NSManaged public var employeeId: Int64
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var title: String?
    @NSManaged public var shift: String?
    @NSManaged public var department: String?
    @NSManaged public var hireDate: Date?
    @NSManaged public var jobTitle: String?
    @NSManaged public var lastUpdated: Date?

}

extension EmployeeEntity : Identifiable {

}
