//
//  OrderView.swift
//  Capstone Project
//
//  Created by user301577 on 10/6/26.
//

import SwiftUI

struct OrderList: View {
    
    @Environment(\.orderRepository) var orderRepository
    @State var viewModel: ViewModel
    
    init(repository: any RepositoryProtocol<Order>) {
        _viewModel = State(wrappedValue: ViewModel(repository: repository))
    }
    
    var body: some View {
        VStack {
            BannerError(model: viewModel)
            
            VStack(spacing: 6) {
                Text("Orders")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
                
                
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
            
          
            
            List(viewModel.groupedOrder, id: \.first?.orderNumber) { lines in if let order = lines.first {
                HStack(alignment: .center, spacing: 12) {
                    Text("\(order.firstName) \(order.lastName) \(order.suffix ?? "")")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 8)
                    
                    Text(String(order.orderNumber))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        viewModel.selectedOrder = order
                    }
                    
                }
                .listRowBackground(rowBackground(for: order))
            }
            }
            .task {
                await viewModel.loadOrders()
            }
        }
        .navigationDestination(item: $viewModel.selectedOrder) { order in OrderDetails(order: order)
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
        
        var errorMessage: String = ""
        
        var orders: [Order] = [] {
            didSet {
                selectedOrder = nil
            }
        }
        
        var selectedOrder: Order? = nil
        
        var groupedOrder: [[Order]] {
            Dictionary(grouping: orders, by: \.orderNumber)
                .values
                .sorted { $0[0].orderNumber < $1[0].orderNumber }
        }
        
        func loadOrders() async {
            errorMessage = ""
            do {
                orders = try await repository.getAll()
            } catch {
                errorMessage = "\(error)"
            }
        }
    }
}
