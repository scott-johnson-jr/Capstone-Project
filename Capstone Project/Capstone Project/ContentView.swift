//
//  ContentView.swift
//  Capstone Project
//
//  Created by user301577 on 9/25/26.


import SwiftUI

struct ContentView: View {
    @Environment(\.employeeRepository) private var employeeRepository

    var body: some View {
        EmployeeList(repository: employeeRepository)
    }
}




#Preview {
    ContentView()
}
