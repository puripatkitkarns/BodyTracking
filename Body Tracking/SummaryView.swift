//
//  SummaryView.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import SwiftUI

struct SummaryView: View {
    let score: Int
    let onPlayAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("Time's Up!")
                .font(.system(size: 70, weight: .black))
                .foregroundColor(.black)
            
            // Large Score Box
            VStack(spacing: 12) {
                Text("Your Score")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.black.opacity(0.7))
                
                Text("\(score)")
                    .font(.system(size: 160, weight: .heavy))
                    .foregroundColor(.black)
            }
            .padding(.vertical, 40)
            .frame(maxWidth: 480)
            .background(Color.white)
            .cornerRadius(40)
            .shadow(radius: 5)
            
            // Big Button
            Button(action: onPlayAgain) {
                Text("Play Again")
                    .font(.system(size: 40, weight: .bold))
                    .frame(width: 350, height: 90)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(45)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
    }
}

