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
                // Product Name
                    Text(item.productName)
                        .font(.headline)
                    
                    HStack(alignment: .center){
                        // Pair red color with a warning symbol for Color Independence
                        HStack(spacing: 4){
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.subheadline) // scales natively with text
                            Text("Stock: \(item.stockLevel)")
                                .bold()
                        }
                        .foregroundColor(.red) // clearly conveys status alongside the symbol
                        
                        Spacer()
                        
                        Text("Reorder Point: \(item.reorderPoint)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding(.vertical, 4)
                // adding combine elements into ssingle clean Voivrover readout
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(item.productName). Low stock status: \(item.stockLevel) available. Reorder point is \(item.reorderPoint).")
            }
            .navigationTitle("Low Stock Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .bold()
                            .padding(.horizontal, 12)
                            .padding(.vertical,8)
                        // gurantees a physical 44x44 minimum touch targest area
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(Rectangle())
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
