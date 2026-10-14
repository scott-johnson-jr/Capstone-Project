//
//  DashboardView.swift
//  Capstone Project
//
//  Created by user302134 on 10/1/26.
//

//
//  DashboardView.swift
//  Capstone Project
//
//  Created by user302134 on 10/1/26.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel = ViewModel()
    @Environment(\.dashboardRepository) private var repository
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading Dashboard...")
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error Loading Data",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else {
                    List {
                        // 1. Weekly Sales Card
                
                        if let latestSales = viewModel.weeklySales.first {
                            WeeklySalesCard(sales: latestSales)
                        }
                        
                        // 2. Low Stock Warning Card
                        LowStockBadgeCard(lowStock: viewModel.lowStock)
                        
                        // 3. Best / Worst Performance Summary
                        BestWorstSummaryCard(bestWorstProducts: viewModel.bestWorstProducts)
                        
                        // 4. Shifts Section
                        ShiftsSection(shifts: viewModel.shifts)
                    }
                }
            }
            .navigationTitle("Manager Dashboard")
            .task {
                await viewModel.fetchDashboardData(using: repository)
            }
        }
    }
}

// MARK: - View Model
extension DashboardView {
    @Observable
    class ViewModel {
        var weeklySales: [WeeklySales] = []
        var bestWorstProducts: [BestWorstProducts] = []
        var lowStock: [LowStock] = []
        var shifts: [Shifts] = []
        
        var isLoading = false
        var errorMessage: String?
        
        @MainActor
        func fetchDashboardData(using repository: any DashboardRepositoryProtocol) async {
            isLoading = true
            errorMessage = nil
            
            do {
                async let salesFetch = repository.getWeeklySales()
                async let productsFetch = repository.getBestWorstProducts()
                async let lowStockFetch = repository.getLowStock()
                async let shiftsFetch = repository.getShifts()
                
                let (sales, products, lowStock, shifts) = try await (
                    salesFetch, productsFetch, lowStockFetch, shiftsFetch
                )
                
                self.weeklySales = sales
                self.bestWorstProducts = products
                self.lowStock = lowStock
                self.shifts = shifts
            } catch let decodingError as DecodingError {
                // Prints the exact missing key or type mismatch to the Xcode Debug Console
                print("JSON Decoding Error: \(decodingError)")
                self.errorMessage = decodingError.localizedDescription
            } catch {
                print("General Error: \(error)")
                self.errorMessage = error.localizedDescription
            }
            
            isLoading = false
        }
    }
}


