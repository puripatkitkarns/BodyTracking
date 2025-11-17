//
//  ContentView.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import SwiftUI
import AVFoundation
import Vision

struct ContentView: View {
    @State var cameraViewModel: CameraViewModel
    @State var poseViewModel: PoseEstimationViewModel
    @State private var showTargetCard = false
    @State private var showTutorial = false

    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
            
            PoseOverlayView(
                bodyParts: poseViewModel.detectedBodyParts,
                connections: poseViewModel.bodyConnections,
                isCorrectPose: poseViewModel.shapeDetected == poseViewModel.targetPose
            )
            
            //HorizontalZoneOverlay(xRange: activeXRange)
            
            VStack {
                HStack {
                    // Score
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Score")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(poseViewModel.score)")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(30)
                    .background(.black.opacity(0.4))
                    .cornerRadius(24)

                    Spacer()

                    // Time
                    VStack(alignment: .trailing, spacing: 12) {
                        Text("Time")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))

                        Text("\(poseViewModel.timeRemaining)")
                            .font(.system(size: 70, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .padding(30)
                    .background(.black.opacity(0.4))
                    .cornerRadius(24)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                if !poseViewModel.isGameRunning && !poseViewModel.gameOver {
                    HStack {
                        // Start Button
                        Button(action: {
                            poseViewModel.startGame()
                        }) {
                            Text("Start Game")
                                .font(.system(size: 40, weight: .bold))
                                .frame(width: 350, height: 90)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(45)
                                .shadow(radius: 10)
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                        Button(action: { showTutorial = true }) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                    }
                    
                } else {
                    // Target Card
                    VStack(alignment: .leading, spacing: 8) {
                        // Animated target card
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                                .frame(width: 140, height: 140) // bigger card
                                .shadow(color: .orange.opacity(0.6), radius: 10, x: 0, y: 5)
                            
                            Text(poseViewModel.targetPose.rawValue)
                                .font(.system(size: 64, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                        }
                        .rotationEffect(.degrees(showTargetCard ? 0 : -15)) // little tilt for excitement
                        .offset(y: showTargetCard ? 0 : 300) // start below screen
                        .scaleEffect(showTargetCard ? 1.0 : 0.6)
                        .opacity(showTargetCard ? 1 : 0)
                        .animation(.interpolatingSpring(stiffness: 200, damping: 8), value: showTargetCard)
                        .onChange(of: poseViewModel.score) {
                            // Animate from below and bounce
                            showTargetCard = false
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 8)) {
                                showTargetCard = true
                            }
                        }
                    }
                }
            }
            .padding()
            
            // Summary
            if poseViewModel.gameOver {
                SummaryView(
                    score: poseViewModel.score,
                    onPlayAgain: {
                        //poseViewModel.startGame()
                        poseViewModel.clearGame()
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
            
        }
        .onAppear {
            showTargetCard = true
        }
        .animation(.easeInOut, value: poseViewModel.gameOver)
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView(onClose: { showTutorial = false })
        }
    }
}
