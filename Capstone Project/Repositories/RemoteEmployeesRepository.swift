//
//  RemoteEmployeesRepository.swift
//  Capstone Project
//
//  Created by user301577 on 9/25/26.
//

import Foundation

class RemoteEmployeeDirectoryRepository {
    
    private let urlBase: String
    
    init(urlBase: String, authStatus: AuthStatus) {
        self.urlBase = urlBase
        super.init(authStatus: authStatus)
    }
    
}
