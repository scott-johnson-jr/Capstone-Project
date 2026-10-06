//
//  WeeklySalesCard.swift
//  Capstone Project
//
//  Created by user302134 on 10/4/26.
//
import SwiftUI

struct WeeklySalesCard: View {
    let sales: WeeklySales

    // Converts ISO string (e.g., "2014-06-17T00:00:00") into formatted date string
    private var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let date = inputFormatter.date(from: sales.salesDate) else {
            return sales.salesDate // Fallback to raw string if parsing fails
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium // e.g., "Jun 17, 2014"
        return outputFormatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Weekly Performance")
                    .font(.headline)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
            
            // Metrics
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Sales")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(sales.totalSales, format: .currency(code: "USD"))
                        .font(.title2)
                        .bold()
                        .monospacedDigit()
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Profit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(sales.totalProfit, format: .currency(code: "USD"))
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.green)
                        .monospacedDigit()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview("Weekly Sales Card") {
    let mockSales =  [
    WeeklySales(
        salesDate: "2014-06-17T00:00:00",
        totalSales: 1364.40,
        totalProfit: 800.28 ),
    WeeklySales(
        salesDate: "2012-06-07T00:00:00",
        totalSales: 1254.20,
        totalProfit: 500.26 )
    
    ]
    
    if let sales = mockSales.first {
        WeeklySalesCard(sales: sales)
            .padding()
    }
}
