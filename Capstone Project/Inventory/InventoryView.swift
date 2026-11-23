import SwiftUI

struct InventoryView: View {
    @StateObject private var viewModel: InventoryViewModel

    init(viewModel: InventoryViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Search")

                TextField("Product or Location", text: $viewModel.filter)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, 4)

            Group {
                if viewModel.isLoading && viewModel.inventory.isEmpty {
                    ProgressView("Loading inventory...")
                } else if viewModel.errorMessage != nil && viewModel.inventory.isEmpty {
                    VStack(spacing: 12) {
                        Text("Unable to load inventory")
                            .font(.headline)
                            .accessibilityAddTraits(.isHeader)

                        Text(viewModel.errorMessage ?? "Please try again.")
                            .multilineTextAlignment(.center)

                        Button("Try Again") {
                            Task {
                                await viewModel.loadInventory()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(minHeight: 44)
                    }
                    .padding()
                } else {
                    VStack(spacing: 8) {
                        if viewModel.isShowingCachedData {
                            VStack(spacing: 8) {
                                Label("Offline Mode", systemImage: "wifi.slash")
                                    .font(.headline)
                                    .foregroundStyle(.orange)

                                Text(viewModel.errorMessage ?? "Showing saved inventory.")
                                    .multilineTextAlignment(.center)

                                Button("Try Again") {
                                    Task {
                                        await viewModel.loadInventory()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .frame(minHeight: 44)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.1))
                        } else if let error = viewModel.errorMessage {
                            VStack(spacing: 8) {
                                Text("Unable to refresh inventory")
                                    .font(.headline)

                                Text(error)
                                    .multilineTextAlignment(.center)

                                Button("Try Again") {
                                    Task {
                                        await viewModel.loadInventory()
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .frame(minHeight: 44)
                            }
                            .padding()
                        }

                        if viewModel.isLoading {
                            ProgressView("Refreshing inventory...")
                                .padding(.vertical, 8)
                        }

                        if viewModel.matchingInventory.isEmpty {
                            Text("No inventory available")
                                .padding()
                        } else {
                            List(viewModel.matchingInventory) { item in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.productName)
                                        .font(.headline)

                                    Text("Location: \(item.locationName)")

                                    Text("Shelf: \(item.shelf)   Bin: \(item.bin)")
                                        .font(.footnote)

                                    Text("Quantity: \(item.quantity)")

                                    Text("Reorder Point: \(item.reorderPoint)")
                                        .font(.footnote)

                                    if item.isLowStock {
                                            Label(
                                                "Low Stock",
                                                systemImage: "exclamationmark.triangle"
                                            )
                                            .foregroundStyle(.red)
                                    }
                                }
                                .padding(.vertical, 4)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel(
                                    "\(item.productName), Location: \(item.locationName), Shelf: \(item.shelf), Bin: \(item.bin), Quantity: \(item.quantity), Reorder Point: \(item.reorderPoint)\(item.isLowStock ? ", Low Stock Warning" : "")"
                                )
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
        }
        .navigationTitle("Inventory")
        .task {
            await viewModel.loadInventory()
        }
    }
}
