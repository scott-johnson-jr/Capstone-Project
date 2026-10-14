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
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task {
                                await viewModel.loadInventory()
                            }
                        }
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
                            }
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
//    InventoryView(viewModel: <#T##InventoryViewModel#>)
//}
