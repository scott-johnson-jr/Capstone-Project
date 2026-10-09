//
//  RepositoryProtocol.swift
//  Capstone Project
//
//  Created by user301577 on 9/29/26.
//
import Foundation
protocol RepositoryProtocol<Item> {
    
    associatedtype Item: Identifiable, Codable
    
    func getAll() async throws -> [Item]
    func getById(_ id: Item.ID) async throws -> Item?

    
    
}


protocol DashboardRepositoryProtocol {
    func getWeeklySales() async throws -> [WeeklySales]
    func getBestWorstProducts() async throws -> [BestWorstProducts]
    func getLowStock() async throws -> [LowStock]
    func getShifts() async throws -> [Shifts]
}
