//
//  RemoteDashboardRepository.swift
//  Capstone Project
//
//  Created by user302134 on 10/1/26.
//


final class RemoteDashboardRepository: DashboardRepositoryProtocol {
    
    private let apiClient: APIClient
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func getWeeklySales() async throws -> [WeeklySales] {
        try await apiClient.fetchWeeklySales()
    }
    
    func getBestWorstProducts() async throws -> [BestWorstProducts] {
        try await apiClient.fetchBestWorstProducts()
    }
    
    func getLowStock() async throws -> [LowStock] {
        try await apiClient.fetchLowStock()
    }
    
    func getShifts() async throws -> [Shifts] {
        try await apiClient.fetchShifts()
    }
}
