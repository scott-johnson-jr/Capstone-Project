//
//  LowStockDetailView.swift
//  Capstone Project
//
//  Created by user302134 on 10/4/26.
//

import SwiftUI

struct LowStockDetailView: View {
    let lowStockItems: [LowStock]
    @Environment(\.dismiss) private var dismiss
        
    var body: some View {
        NavigationStack {
            List(lowStockItems, id: \.productId) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.productName)
                        .font(.headline)
                    HStack{
                        Text("Stock: \(item.stockLevel)")
                            .foregroundStyle(.red)
                            .bold()
                        
                        Spacer()
                        
                        Text("Reorder Point: \(item.reorderPoint)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Low Stock Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done"){
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview("Low Stock Detail View") {
    let mockStock = [
        LowStock(
            productId: 680,
            productName: "Mountain Bike Zero, 901",
            stockLevel: 0,
            reorderPoint: 375
        ),
        LowStock(
            productId: 681,
            productName: "Road Helmet, Red",
            stockLevel: 2,
            reorderPoint: 15
        )
    ]
    
    LowStockDetailView(lowStockItems: mockStock)
}
