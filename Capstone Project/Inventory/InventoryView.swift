//
//  InventoryView.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import SwiftUI
struct InventoryView: View {
    @StateObject private var viewModel: InventoryViewModel
    init(viewModel: InventoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading inventory...")
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Text("Unable to load inventory")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader) // NOTE: Identifies error title as a header for VoiceOver
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadInventory()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(minHeight: 44) // NOTE: Ensures minimum 44pt touch target requirement for retry button
                    }
                    .padding()
                } else if viewModel.inventory.isEmpty {
                    Text("No inventory available")
                } else {
                    List(viewModel.inventory) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.productName)
                                .font(.headline)
                            Text("Location: \(item.locationName)")
                            Text("Quantity: \(item.quantity)")
                            Text("Reorder Point: \(item.reorderPoint)")
                            if item.isLowStock {
                                Label(
                                    "Low Stock",
                                    systemImage: "exclamationmark.triangle"
                                )
                                .foregroundStyle(.red) // NOTE: Explicitly colored text alongside icon for clear low-stock identification
                            }
                        }
                        .padding(.vertical, 4)
                        // NOTE: Combined list row elements so VoiceOver reads product details, quantities, and stock status cohesively as a single button/element
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.productName), Location: \(item.locationName), Quantity: \(item.quantity), Reorder Point: \(item.reorderPoint)\(item.isLowStock ? ", Low Stock Warning" : "")")
                    }
                }
            }
            .navigationTitle("Inventory")
        }
        .task {
            await viewModel.loadInventory()
        }
    }
}


//#Preview {
//    InventoryView(viewModel: <#T##InventoryViewModel#>)
//}
