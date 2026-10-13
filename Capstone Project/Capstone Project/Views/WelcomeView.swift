//
//  WelcomeView.swift
//  CapstoneProject
//
//  Created by user302134 on 9/19/26.
//


import SwiftUI

struct WelcomeView: View {
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.5)
                .ignoresSafeArea()
            
            // NOTE: Wrapped in ScrollView to ensure adaptability across orientations and extreme Dynamic Type sizes without clipping
            ScrollView {
                VStack {
                    Image(systemName: "sun.max.circle")
                        .foregroundColor(.yellow)
                        .font(.system(size: 180,weight: .regular))
                        .dynamicTypeSize(DynamicTypeSize.accessibility3)
                        .padding()
                        // NOTE: Hides decorative sun icon from VoiceOver as it's purely visual
                        .accessibilityHidden(true)
                    
                    Text("Have a groovy day, Adventure Works' associate!")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                        // NOTE: Identifies the welcome text as a screen header for VoiceOver
                        .accessibilityAddTraits(.isHeader)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
    }
    
}



#Preview {
    WelcomeView()
}
