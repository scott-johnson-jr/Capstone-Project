//
//  EnvironmentExtensions.swift
//  Capstone Project
//
//  Created by user301577 on 9/29/26.
//

import SwiftUI

extension EnvironmentValues {
    
    var employeeRepository: any RepositoryProtocol<Employee> {
        get { self [EmployeeRepositoryKey.self] }
        
    }
}
