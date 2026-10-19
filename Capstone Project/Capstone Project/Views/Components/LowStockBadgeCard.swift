//
//  LowStockBadgeCard.swift
//  Capstone Project
//
//  Created by user302134 on 10/4/26.
//

import SwiftUI

struct LowStockBadgeCard: View {
    let lowStock: [LowStock]
    
    // State to manage the popup sheet presentation
    @State private var isShowingDetail = false
    
    // computed property to calculate array count
    var count: Int {
        lowStock.count
    }
    
    var body: some View {
        NavigationLink(destination: LowStockDetailView(lowStockItems: lowStock)) {
            VStack{
                Text("Low Stock Warnings!")
                    .font(.title)
                
                HStack {
                    Text("\(count)")
                        .foregroundColor(.red)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .accessibilityIdentifier("lowStockDashboardCard")
    }
    
    
}




#Preview("Low Stock Overview") {
    let mockStock = [
        LowStock(
            productId: 680,
            productName: "Mountain Bike Zero, 901",
            stockLevel: 0,
            reorderPoint: 375
        ),
        LowStock(
            productId: 706,
            productName: "HL Road Frame - Red, 60",
            stockLevel: 0,
            reorderPoint: 375
        ),
        LowStock(
            productId: 717,
            productName: "HL Road Frame - Red, 62",
            stockLevel: 0,
            reorderPoint: 375
        ),
        LowStock(
            productId: 718,
            productName: "HL Road Frame - Red, 44",
            stockLevel: 0,
            reorderPoint: 375
        )
    ]
    
    LowStockBadgeCard(lowStock: mockStock)
        .padding()
}





