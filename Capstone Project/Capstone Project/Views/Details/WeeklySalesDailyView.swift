//
//  WeeklySalesDailyView.swift
//  Capstone Project
//
//  Created by user302134 on 10/17/26.
//

import SwiftUI
import Charts

struct WeeklySalesDailyView: View {
    let dailySales: [WeeklySales]
    @Environment(\.dismiss) private var dismiss
    
    // State and Enum for the toggle filter
    @State private var selectedFilter: SalesFilter = .all
    
    enum SalesFilter: String, CaseIterable, Identifiable {
        case all = "All Days"
        case week1 = "Week 1"
        case week2 = "Week 2"
        var id: String { self.rawValue }
    }
    
    // Robust filter based on calendar dates with non-optional parsedDate handling
    var displayedSales: [WeeklySales] {
        guard let firstDate = dailySales.first?.parsedDate else { return dailySales }
        
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: 7, to: firstDate) ?? firstDate
        
        switch selectedFilter {
        case .all:
            return dailySales
        case .week1:
            return dailySales.filter { $0.parsedDate < cutoffDate }
        case .week2:
            return dailySales.filter { $0.parsedDate >= cutoffDate }
        }
    }
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Segmented Picker toggle placed at the top of the view
                Picker("View Range", selection: $selectedFilter) {
                    ForEach(SalesFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Header with a scroll hint indicator
                HStack {
                    Text("Daily Trend")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("Swipe to scroll", systemImage: "arrow.left.and.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Horizontal scroll wrapper to prevent date crowding
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart(displayedSales) { item in
                        BarMark(
                            x: .value("Date", item.shortDateLabel),
                            y: .value("Sales ($)", item.totalSales)
                        )
                        .foregroundStyle(.blue.gradient.opacity(0.8))
                        
                        LineMark(
                            x: .value("Date", item.shortDateLabel),
                            y: .value("Profit ($)", item.totalProfit)
                        )
                        .foregroundStyle(.orange)
                        .symbol(Circle())
                        .lineStyle(StrokeStyle(lineWidth: 4))
                    }
                    // Adds extra headroom domain so top values like 3,000 never get clipped
                    .chartYScale(domain: 0...3500)
                    // Dynamically adjusts width based on item count so labels never overlap
                    .frame(width: max(350, CGFloat(displayedSales.count) * 55), height: 320)
                    .padding(.trailing, 10)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                .accessibilityIdentifier("weeklySalesChart")
                .accessibilityLabel("Weekly Sales and Profit Chart")
                .accessibilityHint("Displays daily sales revenue and profit trends for the week.")
            }
            .padding(.vertical)
        }
        .navigationTitle("Weekly Sales Detail")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Removes default back button from Nav Stack
        .accessibilityIdentifier("weeklySalesDetailView")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .bold()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    // gurantees a physical 44x44 minimum touch targest area
                        .frame(minWidth: 44, minHeight: 44)
                        .contentShape(Rectangle())
                }
            }
        }
    }
}

#Preview("Weekly Sales Daily View") {
    let mockSales = [
        WeeklySales(salesDate: "2014-06-20T00:00:00", totalSales: 1153.38, totalProfit: 598.5061),
        WeeklySales(salesDate: "2014-06-21T00:00:00", totalSales: 1823.92, totalProfit: 987.7675),
        WeeklySales(salesDate: "2014-06-22T00:00:00", totalSales: 1505.83, totalProfit: 802.9030),
        WeeklySales(salesDate: "2014-06-23T00:00:00", totalSales: 1937.95, totalProfit: 1116.5620),
        WeeklySales(salesDate: "2014-06-24T00:00:00", totalSales: 1351.26, totalProfit: 749.2949)
    ]
    
    NavigationStack {
        WeeklySalesDailyView(dailySales: mockSales)
    }
}
