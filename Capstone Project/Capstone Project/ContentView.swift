import SwiftUI

struct ContentView: View {
    @Environment(\.employeeRepository) private var employeeRepository
    @Environment(\.inventoryRepository) private var inventoryRepository
    @Environment(\.orderRepository) private var orderRepository
    
    @State private var current: String = "welcome"
    
    private let repository = RemoteDashboardRepository(apiClient: APIClient())
    
    var body: some View {
        NavigationStack {
            VStack {
                switch current {
                    
                case "employees":
                    EmployeeList(repository: employeeRepository)
                        .accessibilityIdentifier("employeeList")

                case "inventory":
                    InventoryView(
                        viewModel: InventoryViewModel(repository: inventoryRepository))
                    .accessibilityIdentifier("inventoryView")

                case "orders":
                    OrderList(repository: orderRepository)
                        .accessibilityIdentifier("orders")

                case "dashboard":
                    DashboardView()
                        .environment(\.dashboardRepository, repository)
                        .accessibilityIdentifier("dashboardView")

                default:
                    WelcomeView()
                        .accessibilityIdentifier("welcomeView")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Welcome Screen") { current = "welcome" }
                            .accessibilityIdentifier("welcomeViewButton")
                        Divider()
                        Button("Employees") { current = "employees" }
                            .accessibilityIdentifier("employeeListButton")
                        
                        Button("Inventory") { current = "inventory" }
                            .accessibilityIdentifier("inventoryViewButton")

                        Button("Orders") { current = "orders" }
                            .accessibilityIdentifier("ordersViewButton")

                        Button("Dashboard") { current = "dashboard" }
                            .accessibilityIdentifier("dashboardViewButton")

                    } label: {
                        Label("View", systemImage: "line.3.horizontal")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
