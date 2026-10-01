//
//  Employee.swift
//  Capstone Project
//
//  Created by user301577 on 9/25/26.
//

import SwiftUI

class Employee: Identifiable, Hashable, Codable {
    
    let employeeId: Int
    let firstName: String
    let lastName: String
    let title: String?
    let shift: String?
    let department: String?
    let hireDate: Date?
    let jobTitle: String
    
    init (
        employeeId: Int,
        firstName: String,
        lastName: String,
        title: String,
        shift: String,
        department: String,
        hireDate: Date,
        jobTitle: String
    ) {
        self.employeeId = employeeId
        self.firstName = firstName
        self.lastName = lastName
        self.title = title
        self.shift = shift
        self.department = department
        self.hireDate = hireDate
        self.jobTitle = jobTitle
    }

    static func == (lhs: Employee, rhs: Employee) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
