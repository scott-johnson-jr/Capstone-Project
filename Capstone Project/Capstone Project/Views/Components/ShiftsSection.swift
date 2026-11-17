//
//  ShiftsSection.swift
//  Capstone Project
//
//  Created by user302134 on 10/4/26.
//

import SwiftUI

struct ShiftsSection: View {
    let shifts: [Shifts]
    
    
    var body: some View {
        VStack{
            Text("Upcoming Shifts")
                .font(.title)
            
            ForEach(shifts) { item in
                HStack {
                    Text("ID: \(item.id)")
                    Spacer()
                    Text("\(item.firstName) \(item.lastName)")
                    Spacer()
                    Text(item.shift)
                }
                
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        
    }
}



#Preview("Shifts Section") {
    let mockShifts = [
        Shifts(
            id: 101,
            firstName: "Alex",
            middleName: nil,
            lastName: "Morgan",
            suffix: nil,
            shift: "Morning"
        ),
        Shifts(
            id: 102,
            firstName: "Jordan",
            middleName: nil,
            lastName: "Lee",
            suffix: nil,
            shift: "Evening"
        )
    ]
    
    ShiftsSection(shifts: mockShifts)
        .padding()
}
