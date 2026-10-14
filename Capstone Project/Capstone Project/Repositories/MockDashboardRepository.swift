//
//  MockDashboardRepository.swift
//  Capstone Project
//
//  Created by user302134 on 10/5/26.
//

import SwiftUI


//Preview to check work

struct MockDashboardRepository: DashboardRepositoryProtocol {
    func getWeeklySales() async throws -> [WeeklySales] {
        [  WeeklySales(
            salesDate: "2014-06-17T00:00:00",
            totalSales: 39120.00,
            totalProfit: 15.75
        ), WeeklySales(
            salesDate: "2016-01-09T00:00:00",
            totalSales: 2543.00,
            totalProfit: 20.50
        )
           ]
    }

    func getBestWorstProducts() async throws -> [BestWorstProducts] {
        [
            BestWorstProducts(productId: 680, productName: "Mountain Bike Zero, 901", unitsSold: 142, unitsInStock: 25),
            BestWorstProducts(productId: 708, productName: "Road Tire Tube", unitsSold: 42, unitsInStock: 80),
            BestWorstProducts(productId: 711, productName: "Road Bottle Cage", unitsSold: 1, unitsInStock: 15)
        ]
    }

    func getLowStock() async throws -> [LowStock] {
        [
            LowStock(productId: 680, productName: "Mountain Bike Zero, 901", stockLevel: 0, reorderPoint: 375),
            LowStock(productId: 708, productName: "Sport-100 Helmet, Red", stockLevel: 3, reorderPoint: 20)
        ]
    }

    func getShifts() async throws -> [Shifts] {
        [
            Shifts(id: 101, firstName: "Alex", middleName: "Paul", lastName: "Morgan", suffix: nil, shift: "Morning"),
            Shifts(id: 102, firstName: "Jordan", middleName: nil, lastName: "Lee", suffix: "Jr", shift: "Evening")
        ]
    }
}

// MARK: - Dashboard Canvas Preview
#Preview("Dashboard Overview") {
    DashboardView()
        .environment(\.dashboardRepository, MockDashboardRepository())
}
