//
//  WeeklySales.swift
//  Capstone Project
//
//  Created by user302134 on 10/1/26.
//
import SwiftUI

class WeeklySales: Identifiable,Codable {
    
    let salesDate: String
    let totalSales: Double
    let totalProfit: Double
    
    
    init(salesDate: String, totalSales: Double, totalProfit: Double){
        self.salesDate = salesDate
        self.totalSales = totalSales
        self.totalProfit = totalProfit
    }
   
    
}
