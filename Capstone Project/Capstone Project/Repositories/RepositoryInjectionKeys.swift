//
//  RepositoryInjectionKeys.swift
//  Capstone Project
//
//  Created by user301577 on 9/29/26.
//

import SwiftUI

struct EmployeeRepositoryKey: EnvironmentKey {
    static let defaultValue: any RepositoryProtocol<Employee> =
    RemoteEmployeeDirectoryRepository(urlBase: "https://api.bootcampcentral.com/api")
}

struct InventoryRepositoryKey: EnvironmentKey {
    static let defaultValue: any InventoryRepositoryProtocol = InventoryRepository(
        apiClient: APIClient()
    )
}
    
struct OrderRepositoryKey: EnvironmentKey {
    static let defaultValue: any RepositoryProtocol<Order> =
    RemoteOrderRepositoryDirectory(urlBase: "https://api.bootcampcentral.com/api")
}
    



struct DashboardRepositoryKey: EnvironmentKey {
    static let defaultValue: any DashboardRepositoryProtocol = RemoteDashboardRepository(
        apiClient: APIClient()
    )
}
