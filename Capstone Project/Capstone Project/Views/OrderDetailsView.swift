//
//  OrderDetailsView.swift
//  Capstone Project
//
//  Created by user301577 on 10/6/26.
//

import SwiftUI

struct OrderDetails: View {
    let order: Order
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Order Summary")
                .font(.title.bold())
                .padding(10)
            
            Rectangle()
                .fill(Color.black)
                .frame(height: 4)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 12) {
                Text("Order #\(String(order.orderNumber))")
                    .font(.title)
                
                
                Text("Customer: \(order.firstName) \(order.lastName) \(order.suffix ?? "")")
                    .font(Font.body.bold())
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 12) {
                        Text("Ordered: \(order.orderDate.formatted(date: .abbreviated, time: .omitted))")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                        Text("Shipped: \(order.shipDate.formatted(date: .abbreviated, time: .omitted))")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .font(.body)
                .foregroundColor(.secondary)
                .padding(10)
                
                VStack(spacing: 8) {
                    Text("Your Item(s):")
                        .foregroundColor(.secondary)
                    
                    Text("Item: \(order.productName)")
                        .font(Font.body.bold())
                    
                    HStack {
                        Text("Quantity")
                            Spacer()
                        Text("\(order.orderQty)")
                    }
                    
                    HStack {
                        Text("Unit Price")
                             Spacer()
                        Text("$\(String(format: "%.2f", order.unitPrice))")
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            Text("Total Price: $\(String(format: "%.2f", order.lineTotal))")
                .font(.title.bold())
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.mint.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
            
        }

    }
    
}
