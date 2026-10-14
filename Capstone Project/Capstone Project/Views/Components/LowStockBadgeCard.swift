//
//  LowStockBadgeCard.swift
//  Capstone Project
//
//  Created by user302134 on 10/4/26.
//

import SwiftUI

struct LowStockBadgeCard: View {
    let lowStock: [LowStock]
    
    // State to manage the popup sheet presentation
    @State private var isShowingDetail = false
    
    // computed property to calculate array count
    var count: Int {
        lowStock.count
    }
    
    var body: some View {
        VStack{
            Text("Low Stock Warnings!")
                .font(.title)
            HStack {
                Text("\(count)")
                Image(systemName: "exclamationmark.triangle.fill")
                
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.red.opacity(0.15))
        .cornerRadius(12)
        // interactive on tap
        .onTapGesture {
            isShowingDetail = true
        }
        .sheet(isPresented: $isShowingDetail) {
            LowStockDetailView(lowStockItems: lowStock)
        }
    }
  
        
    }




#Preview("Low Stock Overview") {
    let mockStock = [
        LowStock(
            productId: 680,
            productName: "Mountain Bike Zero, 901",
            stockLevel: 0,
            reorderPoint: 375
        ),
        LowStock(
            productId: 706,
            productName: "HL Road Frame - Red, 60",
            stockLevel: 0,
            reorderPoint: 375
        ),
        LowStock(
            productId: 717,
            productName: "HL Road Frame - Red, 62",
            stockLevel: 0,
            reorderPoint: 375
        ),
        LowStock(
            productId: 718,
            productName: "HL Road Frame - Red, 44",
            stockLevel: 0,
            reorderPoint: 375
        )
    ]
    
    LowStockBadgeCard(lowStock: mockStock)
        .padding()
}


    
 
   
