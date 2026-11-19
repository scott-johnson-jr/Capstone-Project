
import SwiftUI
import Observation

struct OrderList: View {
    @Environment(\.orderProductRepository)
    private var orderProductRepository

    @State private var viewModel: ViewModel

    init(repository: any RepositoryProtocol<Order>) {
        _viewModel = State(
            wrappedValue: ViewModel(repository: repository)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            BannerError(model: viewModel)

            VStack(spacing: 6) {
                Text("Orders")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)

                Rectangle()
                    .fill(Color.primary)
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)

                HStack {
                    Text("Search")

                    TextField(
                        "Name or Order #",
                        text: $viewModel.filter
                    )
                    .accessibilityLabel("Search orders by name or order number")

                }
                .padding()

                HStack {
                    Text("Name")
                    Spacer(minLength: 16)
                    Text("Order Number")
                }
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, 4)

            List {
                if viewModel.isLoadingOrders && viewModel.orders.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView("Loading orders...")
                        Spacer()
                    }
                }

                if let error = viewModel.ordersErrorMessage {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                "Unable to load orders",
                                systemImage: "wifi.exclamationmark"
                            )
                            .font(.headline)

                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Button("Try Again") {
                                Task {
                                    await viewModel.loadOrders()
                                }
                            }
                            .disabled(viewModel.isLoadingOrders)
                        }
                        .padding(.vertical, 6)
                    }
                }

                if viewModel.orders.isEmpty &&
                    !viewModel.isLoadingOrders &&
                    viewModel.ordersErrorMessage == nil {

                    ContentUnavailableView(
                        "No Orders",
                        systemImage: "cart",
                        description: Text("There are currently no orders to display.")
                    )
                }

                if !viewModel.orders.isEmpty &&
                    viewModel.matchingOrders.isEmpty {

                    ContentUnavailableView.search(
                        text: viewModel.filter
                    )
                }

                ForEach(
                    viewModel.groupedOrder,
                    id: \.first?.orderNumber
                ) { lines in
                    if let order = lines.first {
                        Button {
                            withAnimation(.easeInOut) {
                                viewModel.selectedOrder = order
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 12) {
                                Text(
                                    "\(order.firstName) \(order.lastName) \(order.suffix ?? "")"
                                )
                                .font(.headline)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                                .foregroundStyle(.primary)

                                Spacer(minLength: 8)

                                Text(String(order.orderNumber))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(
                            rowBackground(for: order)
                        )
                    }
                }

                if let error = viewModel.productsErrorMessage {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label(
                                "Order product details unavailable",
                                systemImage: "exclamationmark.triangle"
                            )
                            .font(.subheadline.bold())

                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Button("Retry Product Loading") {
                                Task {
                                    await viewModel.loadProducts(
                                        using: orderProductRepository
                                    )
                                }
                            }
                            .disabled(viewModel.isLoadingProducts)
                        }
                        .padding(.vertical, 6)
                    }
                }

                if viewModel.isLoadingProducts {
                    HStack {
                        ProgressView("Loading product details...")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh(
                    productsRepository: orderProductRepository
                )
            }
        }
        .navigationDestination(item: $viewModel.selectedOrder) { order in
            OrderDetails(
                order: order,
                product: viewModel.products.first {
                    $0.name == order.productName
                }
            )
        }
        .task {
            await viewModel.loadOrders()
            await viewModel.loadProducts(
                using: orderProductRepository
            )
        }
    }

    private func rowBackground(for order: Order) -> Color {
        if viewModel.selectedOrder?.id == order.id {
            Color.gray.opacity(0.25)
        } else {
            Color(.secondarySystemGroupedBackground)
        }
    }
}

extension OrderList {
    @Observable
    class ViewModel: Failable {
        private let repository: any RepositoryProtocol<Order>

        init(repository: any RepositoryProtocol<Order>) {
            self.repository = repository
        }

        var orders: [Order] = [] {
            didSet {
                filter = ""
                selectedOrder = nil
            }
        }

        var products: [OrderProduct] = []

        var filter: String = ""

        var selectedOrder: Order?

        private(set) var isLoadingOrders = false
        private(set) var isLoadingProducts = false

        private(set) var ordersErrorMessage: String?
        private(set) var productsErrorMessage: String?

        var errorMessage: String {
            [
                ordersErrorMessage,
                productsErrorMessage
            ]
            .compactMap { $0 }
            .joined(separator: "\n")
        }

        var matchingOrders: [Order] {
            orders.filter { order in
                filter.isEmpty ||
                "\(order.firstName) \(order.lastName)"
                    .localizedCaseInsensitiveContains(filter) ||
                String(order.orderNumber).contains(filter)
            }
        }

        var groupedOrder: [[Order]] {
            Dictionary(
                grouping: matchingOrders,
                by: \.orderNumber
            )
            .values
            .sorted {
                $0[0].orderNumber < $1[0].orderNumber
            }
        }

        func loadOrders() async {
            guard !isLoadingOrders else { return }

            isLoadingOrders = true
            ordersErrorMessage = nil

            defer {
                isLoadingOrders = false
            }

            do {
                let loadedOrders = try await repository.getAll()
                orders = loadedOrders
            } catch {
                ordersErrorMessage =
                    "Unable to load orders. Check your connection and try again."
            }
        }

        func loadProducts(
            using repository: any RepositoryProtocol<OrderProduct>
        ) async {
            guard !isLoadingProducts else { return }

            isLoadingProducts = true
            productsErrorMessage = nil

            defer {
                isLoadingProducts = false
            }

            do {
                let loadedProducts = try await repository.getAll()
                products = loadedProducts
            } catch {
                productsErrorMessage =
                    "Unable to load order product details. Please try again."
            }
        }

        func refresh(
            productsRepository: any RepositoryProtocol<OrderProduct>
        ) async {
            async let ordersTask: Void = loadOrders()
            async let productsTask: Void = loadProducts(
                using: productsRepository
            )

            _ = await (ordersTask, productsTask)
        }
    }
}

