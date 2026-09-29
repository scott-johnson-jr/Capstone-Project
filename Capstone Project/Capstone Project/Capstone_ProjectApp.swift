//
//  Capstone_ProjectApp.swift
//  Capstone Project
//
//  Created by user301577 on 9/25/26.
//

import SwiftUI
internal import CoreData

@main
struct Capstone_ProjectApp: App {
    
    let awAPIURL = "https://api.bootcampcentral.com/api/"
    @StateObject var authStatus = AuthStatus()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
