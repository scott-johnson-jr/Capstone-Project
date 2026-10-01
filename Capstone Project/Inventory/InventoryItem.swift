//
//  InventoryItem.swift
//  Capstone Project
//
//  Created by user301577 on 10/1/26.
//

import Foundation
struct InventoryItem: Codable, Identifiable {
    let productId: Int
    let productName: String
    let productNumber: String
    let safetyStockLevel: Int
    let reorderPoint: Int
    let locationId: Int
    let locationName: String
    let shelf: String
    let bin: Int
    let quantity: Int
    var id: String {
        "\(productId)-\(locationId)"
    }
    var isLowStock: Bool {
        quantity <= reorderPoint
    }
}
