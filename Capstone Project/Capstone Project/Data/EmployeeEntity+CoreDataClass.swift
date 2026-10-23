//
//  EmployeeEntity+CoreDataClass.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//
//

public import Foundation
public import CoreData

public typealias EmployeeEntityCoreDataClassSet = NSSet

@objc(EmployeeEntity)
public class EmployeeEntity: NSManagedObject, Codable {

enum CodingKeys: String, CodingKey {
    case employeeId
    case firstName
    case lastName
    case title
    case shift
    case department
    case hireDate
    case jobTitle
}

public required convenience init(from decoder: any Decoder) throws {
    guard let context = decoder.userInfo[
        CodingUserInfoKey.managedObjectContext
    ] as? NSManagedObjectContext else {
        throw DecoderConfigurationError.missingManagedObjectContext
    }

    self.init(context: context)

    let container = try decoder.container(keyedBy: CodingKeys.self)

    employeeId = try container.decode(Int64.self, forKey: .employeeId)

    firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
    lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
    title = try container.decodeIfPresent(String.self, forKey: .title)
    shift = try container.decodeIfPresent(String.self, forKey: .shift)
    department = try container.decodeIfPresent(String.self, forKey: .department)
    hireDate = try container.decodeIfPresent(Date.self, forKey: .hireDate)
    jobTitle = try container.decodeIfPresent(String.self, forKey: .jobTitle)

    lastUpdated = Date()
}

public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(employeeId, forKey: .employeeId)
    try container.encodeIfPresent(firstName, forKey: .firstName)
    try container.encodeIfPresent(lastName, forKey: .lastName)
    try container.encodeIfPresent(title, forKey: .title)
    try container.encodeIfPresent(shift, forKey: .shift)
    try container.encodeIfPresent(department, forKey: .department)
    try container.encodeIfPresent(hireDate, forKey: .hireDate)
    try container.encodeIfPresent(jobTitle, forKey: .jobTitle)
}

}
