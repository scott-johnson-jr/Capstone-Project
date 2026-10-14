//
//  BestWorstProducts.swift
//  Capstone Project
//
//  Created by user302134 on 10/1/26.
//

import SwiftUI

class BestWorstProducts: Identifiable,Codable,Hashable {
    
    let productId: Int
    let productName: String
    let unitsSold: Int
    let unitsInStock: Int
    
    init(productId: Int, productName: String,unitsSold: Int, unitsInStock: Int){
        self.productId = productId
        self.productName = productName
        self.unitsSold = unitsSold
        self.unitsInStock = unitsInStock
    }
    
    
    static func == (lhs: BestWorstProducts, rhs: BestWorstProducts) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}


    
