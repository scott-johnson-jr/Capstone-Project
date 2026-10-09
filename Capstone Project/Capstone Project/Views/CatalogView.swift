import SwiftUI

struct CatalogView: View {
    @State private var query = ""
    @State private var category: Product.Category = .all

    private var products: [Product] {
        Catalog.products.filter { product in
            let matchesCategory = category == .all || product.category == category
            let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesQuery = text.isEmpty
                || product.name.localizedCaseInsensitiveContains(text)
                || product.brand.localizedCaseInsensitiveContains(text)
            return matchesCategory && matchesQuery
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    categoryPicker
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
            .background(Color.catalogBackground)
            .navigationTitle("Catalog")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .searchable(text: $query, prompt: "Search products")
        }
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

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Product.Category.allCases) { item in
                    Button {
                        category = item
                    } label: {
                        Text(item.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                category == item ? Color.primary : Color.cardBackground,
                                in: Capsule()
                            )
                            .foregroundStyle(category == item ? Color.catalogBackground : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ProductCard: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProductMark(product: product, size: 54)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(product.brand.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(product.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            Text(product.price.currencyString)
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
