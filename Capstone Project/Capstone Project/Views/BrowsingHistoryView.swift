
import SwiftUI

struct BrowsingHistoryView: View {
    @Environment(\.browsingHistoryRepository)
    private var browsingHistoryRepository

    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if products.isEmpty && isLoading {
                ProgressView("Loading browsing history...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else if products.isEmpty && errorMessage != nil {
                ContentUnavailableView {
                    Label(
                        "Unable to Load Browsing History",
                        systemImage: "wifi.exclamationmark"
                    )
                } description: {
                    Text(errorMessage ?? "Please try again.")
                } actions: {
                    Button("Try Again") {
                        Task {
                            await loadHistory()
                        }
                    }
                }

            } else if products.isEmpty {
                ContentUnavailableView(
                    "No Browsing History",
                    systemImage: "clock.arrow.circlepath",
                    description: Text(
                        "Products you view will appear here."
                    )
                )

            } else {
                historyList
            }
        }
        .navigationTitle("Browsing History")
        .task {
            await loadHistory()
        }
    }

    private var historyList: some View {
        List {
            if let errorMessage {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(
                            "Unable to refresh browsing history",
                            systemImage: "exclamationmark.triangle"
                        )
                        .font(.subheadline.weight(.semibold))

                        Text(errorMessage)
                            .font(.caption)

                        Button("Try Again") {
                            Task {
                                await loadHistory()
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
            await loadHistory()
        }
    }

    @MainActor
    private func loadHistory() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            products = try await browsingHistoryRepository.getRecentlyViewed()
        } catch {
            errorMessage = "Please try again."
        }
    }
}

#Preview {
    NavigationStack {
        BrowsingHistoryView()
    }
}
