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
                    ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                        // changed alignment to .top so elements stay neat if text grows or wraps
                        HStack(alignment: .top){
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.productName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(nil) // allows name to wrap down to a new line instead of truncating
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
                                .fixedSize(horizontal: true, vertical: false) // gurantees the badge content never squishes
                        }
                        // Combine elements into a single clean VoiceOver readout
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(item.productName): \(item.unitsSold) sold.")
                    }
                
            }
            .navigationTitle("Product Performance")
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
