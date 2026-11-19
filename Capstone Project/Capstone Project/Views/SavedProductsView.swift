
import SwiftUI

struct SavedProductsView: View {
    @Environment(\.savedProductsRepository)
    private var savedProductsRepository

    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if products.isEmpty && isLoading {
                ProgressView("Loading saved products...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if products.isEmpty && errorMessage != nil {
                ContentUnavailableView {
                    Label(
                        "Unable to Load Saved Products",
                        systemImage: "wifi.exclamationmark"
                    )
                } description: {
                    Text(errorMessage ?? "Please try again.")
                } actions: {
                    Button("Try Again") {
                        Task {
                            await loadSavedProducts()
                        }
                    }
                }

            } else if products.isEmpty {
                ContentUnavailableView(
                    "No Saved Products",
                    systemImage: "bookmark",
                    description: Text(
                        "Products you save will appear here."
                    )
                )

            } else {
                savedProductsList
            }
        }
        .navigationTitle("Saved Products")
        .task {
            await loadSavedProducts()
        }
    }

    private var savedProductsList: some View {
        List {
            if let errorMessage {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(
                            "Unable to refresh saved products",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.subheadline.weight(.semibold))

                        Text(errorMessage)
                            .font(.caption)

                        Button("Try Again") {
                            Task {
                                await loadSavedProducts()
                            }
                        }
                    }
                }
            }

            Section {
                ForEach(products) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                    } label: {
                        HStack(spacing: 14) {
                            ProductMark(product: product, size: 48)

                            VStack(alignment: .leading, spacing: 5) {
                                Text(product.name)
                                    .font(.headline)

                                Text(product.productNumber)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(product.listPrice.currencyString)
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
        .refreshable {
            await loadSavedProducts()
        }
    }

    @MainActor
    private func loadSavedProducts() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            products = try await savedProductsRepository.getSavedProducts()
        } catch {
            errorMessage = "Please check your connection or try again."
        }
    }
}

#Preview {
    NavigationStack {
        SavedProductsView()
    }
}
