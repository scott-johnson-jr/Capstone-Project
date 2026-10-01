//
//  WelcomeView.swift
//  CapstoneProject
//
//  Created by user302134 on 9/19/26.
//


import SwiftUI

struct WelcomeView: View {
    
    
    var scale = 10.0
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.5)
                .ignoresSafeArea()
            VStack{
                Image(systemName: "sun.max.circle")
                    .foregroundColor(.yellow)
                    .scaleEffect(scale)
                    .padding(40)
                
                
                
                
                Text("Have a groovy day, Adventure Works' associate!")
                    .font(.largeTitle)
                    .padding(40)
            }
        }
    }
    
}



#Preview {
    WelcomeView()
}
