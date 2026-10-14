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
    var orderRepository: any RepositoryProtocol<Order> {
        get { self[OrderRepositoryKey.self] }
        set { self[OrderRepositoryKey.self] = newValue }
    }
    
    var dashboardRepository: any DashboardRepositoryProtocol {
        get { self[DashboardRepositoryKey.self] }
        set { self[DashboardRepositoryKey.self] = newValue }
    }
    
    var orderProductRepository: any RepositoryProtocol<OrderProduct> {
        get { self[OrderProductRepositoryKey.self] }
        set { self[OrderProductRepositoryKey.self] = newValue }
    }
}



