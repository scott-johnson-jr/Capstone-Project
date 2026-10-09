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
       
        
                case "inventory":
                    InventoryView(
                        viewModel: InventoryViewModel(repository: inventoryRepository))
                case "orders":
                    OrderList(repository: orderRepository)
                        
                case "dashboard":
                    DashboardView()
                        .environment(\.dashboardRepository, repository)
                default:
                    WelcomeView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("Welcome Screen") { current = "welcome" }
                        Divider()
                        Button("Employees") { current = "employees" }
                        Button("Inventory") { current = "inventory" }
                        Button("Orders") { current = "orders" }
                        Button("Dashboard") { current = "dashboard" }
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
