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
            
            MovingGradientBackground()
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

struct MovingGradientBackground: View {
    @State private var animate = false

    
    var body: some View {
        LinearGradient(
            colors: [.yellow, .green, .blue],
            startPoint: animate ? .topTrailing : .topLeading,
            endPoint: animate ? .bottomLeading : .bottomTrailing)
            .blur(radius: 50)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animate.toggle()
                }
            }
    }
    
}



#Preview {
    WelcomeView()
}
