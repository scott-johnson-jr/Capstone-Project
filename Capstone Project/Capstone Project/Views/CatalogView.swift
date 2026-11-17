import SwiftUI

struct CatalogView: View {
    @Environment(\.productRepository) private var repository
    @State private var viewModel = CatalogViewModel()
    @State private var query = ""

    private var products: [Product] {
        guard case .loaded(let all) = viewModel.state else { return [] }
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return all }
        return all.filter {
            $0.name.localizedCaseInsensitiveContains(text)
                || $0.productNumber.localizedCaseInsensitiveContains(text)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading catalog…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failed(let message):
                    ContentUnavailableView {
                        Label("Couldn't load catalog", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try again") {
                            Task { await viewModel.load(using: repository) }
                        }
                    }
                case .loaded:
                    catalogContent
                }
            }
            .background(Color.catalogBackground)
            .navigationTitle("Catalog")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .searchable(text: $query, prompt: "Search products")
            .task { await viewModel.load(using: repository) }
        }
    }

    private var catalogContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if products.isEmpty {
                    ContentUnavailableView.search(text: query)
                        .padding(.top, 40)
                } else {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 14),
                            GridItem(.flexible(), spacing: 14)
                        ],
                        spacing: 14
                    ) {
                        ForEach(products) { product in
                            NavigationLink(value: product) {
                                ProductCard(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)
        }
        .refreshable { await viewModel.load(using: repository) }
    }
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("In stock")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Text("\(products.count) pieces")
                .font(.title2.weight(.semibold))
        }
    }

}

#Preview {
    CatalogView()
}

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProductMark(product: product, size: 54)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(product.productNumber.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(product.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            Text(product.listPrice.currencyString)
                .font(.subheadline.weight(.semibold))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

#Preview {
    CatalogView()
}
