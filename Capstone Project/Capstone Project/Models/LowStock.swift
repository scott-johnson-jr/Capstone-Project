//
//  LowStock.swift
//  Capstone Project
//
//  Created by user302134 on 10/1/26.
//
//

import SwiftUI

class LowStock: Identifiable,Codable,Hashable {
    
    let productId: Int
    let productName: String
    let stockLevel: Int
    let reorderPoint: Int
    
    init(productId: Int,productName: String,stockLevel: Int,reorderPoint: Int){
        self.productId = productId
        self.productName = productName
        self.stockLevel = stockLevel
        self.reorderPoint = reorderPoint
    }
    
    
    static func == (lhs: LowStock, rhs: LowStock) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}


    

