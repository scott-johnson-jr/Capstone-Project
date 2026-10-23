import SwiftUI

struct ContentView: View {
    @Environment(\.employeeRepository) private var employeeRepository
    @Environment(\.inventoryRepository) private var inventoryRepository
    @Environment(\.orderRepository) private var orderRepository
    
//    @State private var isLoggedIn = false
    @State private var current: String = "welcome"
    @State private var showDrawer: Bool = false
    
    private let repository = RemoteDashboardRepository(apiClient: APIClient())
    
    var body: some View {
//        if isLoggedIn {
        NavigationStack {
            ZStack {
                // Main content switcher
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
                  case "productCatalog":
                      CatalogView()
                          .accessibilityIdentifier("productView")
//                    case "logout":
//                        Name()
//                        .accessibilityIdentifier("logout")
    
                    default:
                        WelcomeView()
                            .accessibilityIdentifier("welcomeView")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            withAnimation {
                                showDrawer.toggle()
                            }
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .imageScale(.large)
                        }
                    }
                }
            }
        }
        .overlay(
            ZStack {
                // Semi-transparent backdrop
                if showDrawer {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showDrawer = false
                            }
                        }
                }
                
                // Slide-out Drawer View
                HStack(spacing: 0) {
                    DrawerView(current: $current, showDrawer: $showDrawer
//                               , isLoggedIn: $isLoggedIn
                    )
                        .frame(width: 250)
                        .offset(x: showDrawer ? 0 : -250)
                    
                    Spacer()
                }
                .ignoresSafeArea()
            }
        )
        .animation(.easeInOut, value: showDrawer)
    }
//        else {
//        LoginView()
//            .accessibilityIdentifier("loginView")
//    }
}

// Dedicated Drawer View preserving your accessibility identifiers
    struct DrawerView: View {
        @Binding var current: String
        @Binding var showDrawer: Bool
//        @Binding var isLoggedIn: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Space for top safe area
                Color.clear
                    .frame(height: 60)
                
                Text("Navigation")
                    .font(.headline)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                
                Button {
                    current = "employees"
                    closeDrawer()
                } label: {
                    Label("Employees", systemImage: "person.2")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                }
                .accessibilityIdentifier("employeeListButton")
                
                Button {
                    current = "inventory"
                    closeDrawer()
                } label: {
                    Label("Inventory", systemImage: "shippingbox")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                }
                .accessibilityIdentifier("inventoryViewButton")
                
                Button {
                    current = "orders"
                    closeDrawer()
                } label: {
                    Label("Orders", systemImage: "list.clipboard")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                }
                .accessibilityIdentifier("ordersViewButton")
                
                Button {
                    current = "dashboard"
                    closeDrawer()
                } label: {
                    Label("Dashboard", systemImage: "chart.bar")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                }
                .accessibilityIdentifier("dashboardViewButton")
                
                Button {
                    current = "productCatalog"
                    closeDrawer()
                } label: {
                    Label("Product Catalog", systemImage: "book")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                }
                .accessibilityIdentifier("productCatalogViewButton")
                
                
                
                Divider()
                // needs to be log out
                Button {
//                    isLoggedIn = false
                    current = "logout"
                    closeDrawer()
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                }
                .accessibilityIdentifier("logoutButton")
                
                
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.systemBackground))
            .ignoresSafeArea()
        }
        
        private func closeDrawer() {
            withAnimation {
                showDrawer = false
            }
        }
    }
//}

#Preview {
    ContentView()
}
