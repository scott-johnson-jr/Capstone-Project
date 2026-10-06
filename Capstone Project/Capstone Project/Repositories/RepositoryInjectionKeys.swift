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



struct DashboardRepositoryKey: EnvironmentKey {
    static let defaultValue: any DashboardRepositoryProtocol = RemoteDashboardRepository(
        apiClient: APIClient()
    )
}
