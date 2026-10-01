//
//  EnvironmentExtensions.swift
//  Capstone Project
//
//  Created by user301577 on 9/29/26.
//

import SwiftUI

extension EnvironmentValues {
    var employeeRepository: any RepositoryProtocol<Employee> {
        get { self[EmployeeRepositoryKey.self] }
        set { self[EmployeeRepositoryKey.self] = newValue }
    }
    
    var inventoryRepository: any InventoryRepositoryProtocol {
        get { self[InventoryRepositoryKey.self] }
        set { self[InventoryRepositoryKey.self] = newValue }
    }
    
}
