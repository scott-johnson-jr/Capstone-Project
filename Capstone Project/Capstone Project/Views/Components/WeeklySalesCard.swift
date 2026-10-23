//
//  WeeklySalesCard.swift
//  Capstone Project
//
//  Created by user302134 on 10/4/26.
//

import SwiftUI

struct WeeklySalesCard: View {
    let dailySalesCard: [WeeklySales]
    
    var totalSales: Double {
        dailySalesCard.reduce(0) { $0 + $1.totalSales }
    }
    
    var totalProfit: Double {
        dailySalesCard.reduce(0) { $0 + $1.totalProfit }
    }
    
    // Pulls the start and end strings directly using model's built-in property
    var dateRangeString: String {
        guard let first = dailySalesCard.first, let last = dailySalesCard.last else { return "" }
        return "\(first.shortDateLabel) - \(last.shortDateLabel)"
    }
    
    var body: some View {
        NavigationLink(destination: WeeklySalesDailyView(dailySales: dailySalesCard)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("This Week's Sales")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Sits right next to the title
                    if !dateRangeString.isEmpty {
                        Text(dateRangeString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
            
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Sales")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(totalSales, specifier: "%.2f")")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Profit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(totalProfit, specifier: "%.2f")")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .accessibilityIdentifier("weeklySalesDashboardCard")
    }
}

#Preview("Weekly Sales Card") {
    let mockSales = [
        WeeklySales(salesDate: "2014-06-20T00:00:00", totalSales: 1153.38, totalProfit: 598.5061),
        WeeklySales(salesDate: "2014-06-21T00:00:00", totalSales: 1823.92, totalProfit: 987.7675),
        WeeklySales(salesDate: "2014-06-22T00:00:00", totalSales: 1505.83, totalProfit: 802.9030),
        WeeklySales(salesDate: "2014-06-23T00:00:00", totalSales: 1937.95, totalProfit: 1116.5620),
        WeeklySales(salesDate: "2014-06-24T00:00:00", totalSales: 1351.26, totalProfit: 749.2949)
    ]
    
    NavigationStack {
        List {
            WeeklySalesCard(dailySalesCard: mockSales)
        }
    }
}



