//
//  BestWorstSummaryCard.swift
//  Capstone Project
//
//  Created by user302134 on 10/4/26.
//


import SwiftUI

struct BestWorstSummaryCard: View {
    let bestWorstProducts: [BestWorstProducts]
    
    // Computed property to assign top seller
    var bestProduct: BestWorstProducts? {
        bestWorstProducts.max(by: { $0.unitsSold < $1.unitsSold })
    }

    // Computed property to assign bottom seller
    var worstProduct: BestWorstProducts? {
        bestWorstProducts.min(by: { $0.unitsSold < $1.unitsSold })
    }
    
    // State to manage the popup sheet presentation
    @State private var isShowingDetail = false
   
    
    var body: some View {
        VStack(spacing: 12){
            HStack(alignment: .center) {
                Text("Top Seller")
                    .font(.title)
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2){
                    Text(bestProduct?.productName ?? "N/A")
                        .lineLimit(1)
                    Text("(\(bestProduct?.unitsSold ?? 0) sold)")
                }
            }
            Divider()
            HStack(alignment: .center) {
               Text("Worst Seller")
                    .font(.title)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(worstProduct?.productName ?? "N/A")
                        .lineLimit(1)
                    Text("(\(worstProduct?.unitsSold ?? 0) sold)")
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        // interactive on tap
        .onTapGesture {
            isShowingDetail = true
        }
        .sheet(isPresented: $isShowingDetail) {
            ProductPerformanceDetailView(bestWorstItems: bestWorstProducts)
        }
    }
  
        
    }




#Preview("Best and Worst Products") {
    let mockProducts = [
        BestWorstProducts(
            productId: 922,
            productName: "Road Tire Tube",
            unitsSold: 42,
            unitsInStock: 505
        ),
        BestWorstProducts(
            productId: 872,
            productName: "Road Bottle Cage",
            unitsSold: 1,
            unitsInStock: 324
        )
    ]
    
    BestWorstSummaryCard(bestWorstProducts: mockProducts)
        .padding()
}


    
 

 

  

