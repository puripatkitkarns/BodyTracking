//
//  TutorialView.swift
//  Body Tracking
//
//  Created by 677112 on 11/17/25.
//

import SwiftUI

struct TutorialView: View {
    let onClose: () -> Void
    @State private var page = 0
    
    var body: some View {
        VStack(spacing: 10) {
            
            // Title
            Text("How to Play")
                .font(.system(size: 70, weight: .black))
                .foregroundColor(.black)
            
            // Paging Slides
            TabView(selection: $page) {
                ForEach(0..<tutorials.count, id: \.self) { i in
                    VStack() {
                        
                        // White Card
                        VStack(spacing: 30) {
                            Image(tutorials[i].image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 280)
                                .cornerRadius(40)
                                .padding(.top, 20)
                            
                            Text(tutorials[i].title)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(tutorials[i].text)
                                .font(.system(size: 20))
                                .foregroundColor(.black.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 80)
                                .padding(.bottom, 20)
                            
                        }
                        .frame(maxWidth: 600)
                        //.background(Color.white)
                        .cornerRadius(40)
                        //.shadow(radius: 5)
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            
            // Close Button
            Button(action: onClose) {
                Text("Got It!")
                    .font(.system(size: 40, weight: .bold))
                    .frame(width: 300, height: 90)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(45)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
    }
}
