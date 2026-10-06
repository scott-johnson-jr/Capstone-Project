//
//  Shifts.swift
//  Capstone Project
//
//  Created by user302134 on 10/1/26.
//

import Foundation

struct Shifts: Identifiable,Codable,Hashable {
    
    let id: Int
    let firstName: String
    let middleName: String?
    let lastName: String
    let suffix: String?
    let shift: String

// adding coding keys to map id to employeeId
    enum CodingKeys: String, CodingKey {
        case id = "employeeId"
        case firstName,middleName,lastName,suffix,shift
    }
        
}



