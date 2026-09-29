//
//  ContentView.swift
//  Capstone Project
//
//  Created by user301577 on 9/25/26.
//

import SwiftUI

struct ContentView: View {
    
    
    var body: some View {
        EmployeeList(repository: RemoteEmployeeDirectoryRepository(urlBase: "https://api.bootcampcentral.com/api"))
        }
    }


#Preview {
    ContentView()
}
