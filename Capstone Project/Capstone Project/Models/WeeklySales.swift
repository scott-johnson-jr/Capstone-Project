//
//  WeeklySales.swift
//  Capstone Project
//
//  Created by user302134 on 10/1/26.
//
import Foundation

class WeeklySales: Identifiable,Codable {
    
    // Use salesDate as the unique ID since each day is unique
    var id: String { salesDate }
    let salesDate: String
    let totalSales: Double
    let totalProfit: Double
    
    enum CodingKeys: String, CodingKey {
        case salesDate, totalSales, totalProfit
    }
    // moved date formatting here since multiple views use it - BB
    var parsedDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: salesDate) ?? Date()
    }
    
    var shortDateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: parsedDate)
    }
    
    init(salesDate: String, totalSales: Double, totalProfit: Double){
        self.salesDate = salesDate
        self.totalSales = totalSales
        self.totalProfit = totalProfit
    }
   
    
}
