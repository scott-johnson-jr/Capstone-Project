//
//  Orders.swift
//  Capstone Project
//
//  Created by user301577 on 10/6/26.
//

import SwiftUI

class Order: Identifiable, Hashable, Codable {
    
    let id: Int
    let customerId: Int
    let firstName: String
    let lastName: String
    let suffix: String?
    let orderDate: Date
    let shipDate: Date
    let productName: String
    let orderNumber: Int
    let orderQty: Int
    let unitPrice: Double
    let lineTotal: Double
    
    init (
        id: Int,
        customerId: Int,
        firstName: String,
        lastName: String,
        suffix: String?,
        orderDate: Date,
        shipDate: Date,
        productName: String,
        orderNumber: Int,
        orderQty: Int,
        unitPrice: Double,
        lineTotal: Double
    ) {
        self.id = id
        self.customerId = customerId
        self.firstName = firstName
        self.lastName = lastName
        self.suffix = suffix
        self.orderDate = orderDate
        self.shipDate = shipDate
        self.productName = productName
        self.orderNumber = orderNumber
        self.orderQty = orderQty
        self.unitPrice = unitPrice
        self.lineTotal = lineTotal
    }
        
     

    static func == (lhs: Order, rhs: Order) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
