//
//  OrderDetailsView.swift
//  Capstone Project
//
//  Created by user301577 on 10/6/26.
//

import SwiftUI

struct OrderDetails: View {
    let order: Order
    let product: OrderProduct?
    
    var body: some View {
        // NOTE: Wrapped in ScrollView to ensure adaptability across orientations and extreme Dynamic Type sizes without clipping
        ScrollView {
            VStack(spacing: 12) {
                Text("Order Summary")
                    .font(.title.bold())
                    .padding(10)
                    .accessibilityAddTraits(.isHeader) // NOTE: Identifies the title as a screen header for VoiceOver
                
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
                
                VStack(spacing: 12) {
                    Text("Order #\(String(order.orderNumber))")
                        .font(.title)
                        .accessibilityAddTraits(.isHeader) // NOTE: Identifies order number as a subheading/header for VoiceOver
                    
                    Text("Customer: \(order.firstName) \(order.lastName) \(order.suffix ?? "")")
                        .font(Font.body.bold())
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        // NOTE: Custom accessibility label to ensure name components read clearly together
                        .accessibilityLabel("Customer: \(order.firstName) \(order.lastName) \(order.suffix ?? "")")
                    
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
                    // NOTE: Combined date elements so screen readers can read order and ship dates cohesively
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Ordered on \(order.orderDate.formatted(date: .abbreviated, time: .omitted)), Shipped on \(order.shipDate.formatted(date: .abbreviated, time: .omitted))")
                    
                    VStack(spacing: 8) {
                        Text("Your Item(s):")
                            .foregroundColor(.secondary)
                        
                        Text("Item: \(order.productName)")
                            .font(Font.body.bold())
                            .accessibilityLabel("Item: \(order.productName)")
                        
                        if let data = product?.thumbnailPhoto, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            
                            
                    }
                    
                    HStack {
                            Text("Quantity")
                            Spacer()
                            Text("\(order.orderQty)")
                        }
                        // NOTE: Combined quantity row for clear VoiceOver reading
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Quantity: \(order.orderQty)")
                        
                        HStack {
                            Text("Unit Price")
                            Spacer()
                            Text("$\(String(format: "%.2f", order.unitPrice))")
                        }
                        // NOTE: Combined unit price row for clear VoiceOver reading
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Unit Price: $\(String(format: "%.2f", order.unitPrice))")
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
                    // NOTE: Clean accessibility label for total price
                    .accessibilityLabel("Total Price: $\(String(format: "%.2f", order.lineTotal))")
                
            }
            .padding()
        }
    }
}
