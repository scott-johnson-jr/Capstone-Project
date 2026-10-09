import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @State private var selectedColor: String
    @State private var added = false

    init(product: Product) {
        self.product = product
        _selectedColor = State(initialValue: product.colors.first ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                titleBlock
                colorPicker
                Text(product.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                specs
            }
            .padding(20)
        }
        .background(Color.catalogBackground)
        .navigationTitle(product.name)
        .safeAreaInset(edge: .bottom) {
            addButton
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
            Text(product.brand.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(product.name)
                .font(.largeTitle.weight(.semibold))
            Text(product.summary)
                .font(.title3)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                Label(String(format: "%.1f", product.rating), systemImage: "star.fill")
                Text("\(product.reviewCount) reviews")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(product.price.currencyString)
                    .font(.title3.weight(.semibold))
            }
            .font(.subheadline)
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
                                selectedColor == color ? Color.primary : Color.cardBackground,
                                in: Capsule()
                            )
                            .foregroundStyle(selectedColor == color ? Color.catalogBackground : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var specs: some View {
        VStack(spacing: 0) {
            ForEach(product.specs) { spec in
                HStack {
                    Text(spec.label)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(spec.value)
                }
                .font(.subheadline)
                .padding(.vertical, 12)
                if spec.id != product.specs.last?.id {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 16)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var addButton: some View {
        Button {
            added = true
        } label: {
            Text(added ? "Added to bag" : "Add to bag · \(product.price.currencyString)")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .foregroundStyle(Color.catalogBackground)
        }
        .buttonStyle(.plain)
        .disabled(added)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
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
                in: RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
            )
    }
}

extension Product.Accent {
    var gradient: LinearGradient {
        switch self {
        case .ink:
            LinearGradient(colors: [Color(white: 0.82), Color(white: 0.62)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .clay:
            LinearGradient(colors: [Color(red: 0.86, green: 0.62, blue: 0.48), Color(red: 0.72, green: 0.45, blue: 0.34)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sage:
            LinearGradient(colors: [Color(red: 0.62, green: 0.72, blue: 0.58), Color(red: 0.42, green: 0.55, blue: 0.42)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .sand:
            LinearGradient(colors: [Color(red: 0.90, green: 0.82, blue: 0.66), Color(red: 0.78, green: 0.66, blue: 0.46)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .dusk:
            LinearGradient(colors: [Color(red: 0.55, green: 0.58, blue: 0.72), Color(red: 0.36, green: 0.38, blue: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

extension Color {
    static let catalogBackground = Color(red: 0.95, green: 0.95, blue: 0.96)
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
        ProductDetailView(product: Catalog.products[0])
    }
}
