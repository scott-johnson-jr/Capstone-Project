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
            VStack(spacing: 0) {
                // Search bar section matching the OrderView pattern
                HStack {
                    Spacer()
                    
                    Text("Search")
                    
                    TextField("Product or Location", text: $viewModel.filter)
                        .textFieldStyle(.roundedBorder)
                    
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
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
                    } else if viewModel.matchingInventory.isEmpty {
                        Text("No inventory available")
                    } else {
                        // Iterates over filtered matchingInventory list
                        List(viewModel.matchingInventory) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.productName)
                                    .font(.headline)
                                Text("Location: \(item.locationName)")
                                Text("Shelf: \(item.shelf)   Bin: \(item.bin)") // added for user story requirement - BB
                                    .font(.footnote) // style edit - BB
                                Text("Quantity: \(item.quantity)")
                                Text("Reorder Point: \(item.reorderPoint)")
                                    .font(.footnote) // style edit - BB
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
                            .accessibilityLabel("\(item.productName), Location: \(item.locationName), Shelf: \(item.shelf), Bin: \(item.bin) Quantity: \(item.quantity), Reorder Point: \(item.reorderPoint)\(item.isLowStock ? ", Low Stock Warning" : "")") // added in Shelf and Bin - BB
                        }
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
//    InventoryView(viewModel: InventoryViewModel())
//}
