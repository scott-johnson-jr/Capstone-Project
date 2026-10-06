//
//  ProductPerformanceDetailView.swift
//  Capstone Project
//
//  Created by user302134 on 10/4/26.
//
import SwiftUI

struct ProductPerformanceDetailView: View {
    let bestWorstItems: [BestWorstProducts]
    @Environment(\.dismiss) private var dismiss
    
    // sort items by unites sold descending
    var sortedItems: [BestWorstProducts] {
        bestWorstItems.sorted { $0.unitsSold > $1.unitsSold}
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Performance Ranking") {
                    ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                        HStack{
                            // rank number badge
                            Text("#\(index + 1)")
                                .font(.caption)
                                .bold()
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.productName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("ID: #\(item.productId)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(item.unitsSold) sold")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.tertiarySystemBackground))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            .navigationTitle("Product Performance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview("Prodcut Performance Detail View") {
    let mockProducts = [
        BestWorstProducts(
            productId: 922,
            productName: "Road Tire Tube",
            unitsSold: 42,
            unitsInStock: 505
        ),
        BestWorstProducts(
            productId: 872,
            productName: "Road Bottle Cage",
            unitsSold: 1,
            unitsInStock: 324
        )
    ]
    
    ProductPerformanceDetailView(bestWorstItems: mockProducts)
}
