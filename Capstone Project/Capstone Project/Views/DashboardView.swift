
import SwiftUI
import Observation

struct DashboardView: View {
    @State private var viewModel = ViewModel()
    @Environment(\.dashboardRepository) private var repository

    var body: some View {
        NavigationStack {
            List {
                dashboardSection(
                    title: "Weekly Sales",
                    isLoading: viewModel.isLoadingSales,
                    hasLoaded: viewModel.hasLoadedSales,
                    error: viewModel.salesError,
                    retry: {
                        await viewModel.loadWeeklySales(using: repository)
                    }
                ) {
                    WeeklySalesCard(
                        dailySalesCard: viewModel.weeklySales
                    )
                }

                dashboardSection(
                    title: "Low Stock",
                    isLoading: viewModel.isLoadingLowStock,
                    hasLoaded: viewModel.hasLoadedLowStock,
                    error: viewModel.lowStockError,
                    retry: {
                        await viewModel.loadLowStock(using: repository)
                    }
                ) {
                    LowStockBadgeCard(
                        lowStock: viewModel.lowStock
                    )
                }

                dashboardSection(
                    title: "Best / Worst Products",
                    isLoading: viewModel.isLoadingProducts,
                    hasLoaded: viewModel.hasLoadedProducts,
                    error: viewModel.productsError,
                    retry: {
                        await viewModel.loadBestWorstProducts(using: repository)
                    }
                ) {
                    BestWorstSummaryCard(
                        bestWorstProducts: viewModel.bestWorstProducts
                    )
                }

                dashboardSection(
                    title: "Shifts",
                    isLoading: viewModel.isLoadingShifts,
                    hasLoaded: viewModel.hasLoadedShifts,
                    error: viewModel.shiftsError,
                    retry: {
                        await viewModel.loadShifts(using: repository)
                    }
                ) {
                    ShiftsSection(shifts: viewModel.shifts)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Manager Dashboard")
            .refreshable {
                await viewModel.refresh(using: repository)
            }
            .task {
                await viewModel.fetchDashboardData(using: repository)
            }
        }
    }

    @ViewBuilder
    private func dashboardSection<Content: View>(
        title: String,
        isLoading: Bool,
        hasLoaded: Bool,
        error: String?,
        retry: @escaping () async -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Section {
            if hasLoaded {
                content()
            } else if isLoading {
                ProgressView("Loading \(title)...")
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            if let error {
                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        "\(title) unavailable",
                        systemImage: "exclamationmark.triangle"
                    )
                    .font(.subheadline.bold())

                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button("Try Again") {
                        Task {
                            await retry()
                        }
                    }
                    .disabled(isLoading)
                }
                .padding(.vertical, 6)
            }
        } header: {
            Text(title)
        }
    }
}

// MARK: - View Model

extension DashboardView {
    @MainActor
    @Observable
    class ViewModel {
        var weeklySales: [WeeklySales] = []
        var bestWorstProducts: [BestWorstProducts] = []
        var lowStock: [LowStock] = []
        var shifts: [Shifts] = []

        private(set) var isLoadingSales = false
        private(set) var isLoadingProducts = false
        private(set) var isLoadingLowStock = false
        private(set) var isLoadingShifts = false

        private(set) var hasLoadedSales = false
        private(set) var hasLoadedProducts = false
        private(set) var hasLoadedLowStock = false
        private(set) var hasLoadedShifts = false

        private(set) var salesError: String?
        private(set) var productsError: String?
        private(set) var lowStockError: String?
        private(set) var shiftsError: String?

        func fetchDashboardData(
            using repository: any DashboardRepositoryProtocol
        ) async {
            await refresh(using: repository)
        }

        func refresh(
            using repository: any DashboardRepositoryProtocol
        ) async {
            async let salesTask: Void = loadWeeklySales(using: repository)
            async let productsTask: Void = loadBestWorstProducts(using: repository)
            async let lowStockTask: Void = loadLowStock(using: repository)
            async let shiftsTask: Void = loadShifts(using: repository)

            _ = await (
                salesTask,
                productsTask,
                lowStockTask,
                shiftsTask
            )
        }

        func loadWeeklySales(
            using repository: any DashboardRepositoryProtocol
        ) async {
            guard !isLoadingSales else { return }

            isLoadingSales = true
            salesError = nil

            defer {
                isLoadingSales = false
            }

            do {
                weeklySales = try await repository.getWeeklySales()
                hasLoadedSales = true
            } catch {
                salesError = "Unable to load weekly sales. Please try again."
            }
        }

        func loadBestWorstProducts(
            using repository: any DashboardRepositoryProtocol
        ) async {
            guard !isLoadingProducts else { return }

            isLoadingProducts = true
            productsError = nil

            defer {
                isLoadingProducts = false
            }

            do {
                bestWorstProducts = try await repository.getBestWorstProducts()
                hasLoadedProducts = true
            } catch {
                productsError = "Unable to load product performance. Please try again."
            }
        }

        func loadLowStock(
            using repository: any DashboardRepositoryProtocol
        ) async {
            guard !isLoadingLowStock else { return }

            isLoadingLowStock = true
            lowStockError = nil

            defer {
                isLoadingLowStock = false
            }

            do {
                lowStock = try await repository.getLowStock()
                hasLoadedLowStock = true
            } catch {
                lowStockError = "Unable to load low-stock information. Please try again."
            }
        }

        func loadShifts(
            using repository: any DashboardRepositoryProtocol
        ) async {
            guard !isLoadingShifts else { return }

            isLoadingShifts = true
            shiftsError = nil

            defer {
                isLoadingShifts = false
            }

            do {
                shifts = try await repository.getShifts()
                hasLoadedShifts = true
            } catch {
                shiftsError = "Unable to load shifts. Please try again."
            }
        }
    }
}

