//
//  Products.swift
//  Capstone Project
//
//  Created by user301577 on 10/12/26.
//

import Foundation
// product model for images in the orderdetails page
struct OrderProduct: Codable, Identifiable {
    let productId: Int
    let name: String
    let thumbnailPhoto: Data?
    let thumbnailPhotoFileName: String?
    
    var id: Int { productId }
}
