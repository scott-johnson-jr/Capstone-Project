
import SwiftUI

struct ProductDetailView: View {
    let product: Product

    @Environment(\.savedProductsRepository)
    private var savedProductsRepository

    @Environment(\.browsingHistoryRepository)
    private var browsingHistoryRepository

    @State private var selectedColor: String
    @State private var added = false
    @State private var isSaved = false
    @State private var isSaving = false
    @State private var saveError: String?

    init(product: Product) {
        self.product = product
        _selectedColor = State(initialValue: product.colors.first ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                titleBlock

                if !product.colors.isEmpty {
                    colorPicker
                }

                if let summary = product.summary, !summary.isEmpty {
                    Text(summary)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                details
            }
            .padding(20)
        }
        .background(Color.catalogBackground)
        .navigationTitle(product.name)
        .safeAreaInset(edge: .bottom) {
            addButton
        }
        .task {
            await recordProductView()
            await loadSavedStatus()
        }
        .alert(
            "Product Details",
            isPresented: Binding(
                get: { saveError != nil },
                set: { if !$0 { saveError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                saveError = nil
            }
        } message: {
            Text(saveError ?? "Something went wrong.")
        }
    }

    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(product.accent.gradient)
                .frame(height: 240)

            ProductMark(product: product, size: 92)
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("#\(product.productId) · \(product.productNumber)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(product.name)
                        .font(.largeTitle.weight(.semibold))

                    Text(product.listPrice.currencyString)
                        .font(.title3.weight(.semibold))
                }

                Spacer()

                Button {
                    Task {
                        await toggleSaved()
                    }
                } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.title2)
                        .foregroundStyle(.primary)
                        .padding(12)
                        .background(
                            Color.cardBackground,
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
                .accessibilityLabel(
                    isSaved ? "Remove from saved products" : "Save product"
                )
                .accessibilityHint(
                    "Adds or removes this product from your saved products."
                )
            }
        }
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Color · \(selectedColor)")
                .font(.subheadline.weight(.medium))

            HStack(spacing: 8) {
                ForEach(product.colors, id: \.self) { color in
                    Button {
                        selectedColor = color
                    } label: {
                        Text(color)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedColor == color
                                    ? Color.primary
                                    : Color.cardBackground,
                                in: Capsule()
                            )
                            .foregroundStyle(
                                selectedColor == color
                                    ? Color.catalogBackground
                                    : .primary
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var detailRows: [(label: String, value: String)] {
        var rows: [(label: String, value: String)] = []

        if let warranty = product.warranty {
            rows.append(("Warranty", warranty.value))
        }

        rows.append(("In stock", "\(product.stockLevel)"))

        return rows
    }

    private var details: some View {
        VStack(spacing: 0) {
            ForEach(Array(detailRows.enumerated()), id: \.offset) {
                index, row in

                HStack {
                    Text(row.label)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(row.value)
                }
                .font(.subheadline)
                .padding(.vertical, 12)

                if index < detailRows.count - 1 {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 16)
        .background(
            Color.cardBackground,
            in: RoundedRectangle(
                cornerRadius: 16,
                style: .continuous
            )
        )
    }

    private var addButton: some View {
        Button {
            added = true
        } label: {
            Text(
                added
                    ? "Added to bag"
                    : "Add to bag · \(product.listPrice.currencyString)"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Color.primary,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .foregroundStyle(Color.catalogBackground)
        }
        .buttonStyle(.plain)
        .disabled(added)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
    }

    // Record this product in browsing history.
    private func recordProductView() async {
        do {
            try await browsingHistoryRepository.recordViewed(product)
        } catch {
            saveError = "Unable to save this product to browsing history."
        }
    }

    private func loadSavedStatus() async {
        do {
            isSaved = try await savedProductsRepository.isSaved(
                productId: product.productId
            )
        } catch {
            saveError = "Unable to check whether this product is saved."
        }
    }

    private func toggleSaved() async {
        guard !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            let newSavedStatus = !isSaved

            try await savedProductsRepository.setSaved(
                newSavedStatus,
                for: product
            )

            isSaved = newSavedStatus
        } catch {
            saveError = "Unable to update your saved products. Please try again."
        }
    }
}

struct ProductMark: View {
    let product: Product
    var size: CGFloat = 54

    var body: some View {
        Image(systemName: product.symbol)
            .font(.system(size: size * 0.42, weight: .medium))
            .foregroundStyle(.primary)
            .frame(width: size, height: size)
            .background(
                product.accent.gradient,
                in: RoundedRectangle(
                    cornerRadius: size * 0.28,
                    style: .continuous
                )
            )
    }
}

extension Product.Accent {
    var gradient: LinearGradient {
        switch self {
        case .ink:
            LinearGradient(
                colors: [Color(white: 0.82), Color(white: 0.62)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .clay:
            LinearGradient(
                colors: [
                    Color(red: 0.86, green: 0.62, blue: 0.48),
                    Color(red: 0.72, green: 0.45, blue: 0.34)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .sage:
            LinearGradient(
                colors: [
                    Color(red: 0.62, green: 0.72, blue: 0.58),
                    Color(red: 0.42, green: 0.55, blue: 0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .sand:
            LinearGradient(
                colors: [
                    Color(red: 0.90, green: 0.82, blue: 0.66),
                    Color(red: 0.78, green: 0.66, blue: 0.46)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .dusk:
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.58, blue: 0.72),
                    Color(red: 0.36, green: 0.38, blue: 0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension Color {
    static let catalogBackground = Color(
        red: 0.95,
        green: 0.95,
        blue: 0.96
    )

    static let cardBackground = Color(red: 1, green: 1, blue: 1)
}

extension Decimal {
    var currencyString: String {
        let number = self as NSDecimalNumber

        return number.stringValue.contains(".")
            ? String(format: "$%.2f", number.doubleValue)
            : "$\(number.intValue)"
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(
            product: Product(
                productId: 1,
                name: "Mountain Bike Zero",
                productNumber: "BK-M18",
                summary: "Sample summary",
                warranty: FlexibleText("12"),
                color: "Black",
                listPrice: 1431.50,
                stockLevel: 20
            )
        )
    }
}

