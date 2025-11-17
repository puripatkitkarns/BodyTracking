//
//  PoseGameView.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import SwiftUI
import AVFoundation
import Vision

struct PoseGameView: View {
    @StateObject var viewModel = PoseGameViewModel()
    
    var body: some View {
        ZStack {
            CameraView { observation in
                viewModel.processPoseObservation(observation)
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Target Pose: \(viewModel.targetPose.rawValue)")
                    .font(.largeTitle)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                
                Text("Score: \(viewModel.score)")
                    .font(.title)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                
                Text("Time: \(viewModel.timeRemaining)")
                    .font(.title2)
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(10)
                
                Spacer()
                
                if !viewModel.isGameRunning {
                    Button("Start Game") {
                        viewModel.startGame()
                    }
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}

