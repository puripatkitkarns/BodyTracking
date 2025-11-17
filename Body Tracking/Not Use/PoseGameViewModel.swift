//
//  PoseGameView.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import SwiftUI
import AVFoundation
import Vision
import Combine

enum TargetPose: String, CaseIterable {
    case O = "O"
    case X = "X"
}

class PoseGameViewModel: ObservableObject {
    @Published var targetPose: TargetPose = .O
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var isGameRunning: Bool = false
    
    private var timer: Timer?
    
    func startGame() {
        score = 0
        timeRemaining = 60
        isGameRunning = true
        targetPose = TargetPose.allCases.randomElement()!
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.isGameRunning = false
                t.invalidate()
            }
        }
    }
    
    func stopGame() {
        isGameRunning = false
        timer?.invalidate()
    }
    
    /// Called by Vision processor whenever we get a new body pose observation
    func processPoseObservation(_ observation: VNHumanBodyPoseObservation) {
        guard isGameRunning else { return }
        
        if poseMatchesTarget(observation) {
            score += 1
            targetPose = TargetPose.allCases.randomElement()!
        }
    }
    
    // MARK: - Pose Classification
    
    private func poseMatchesTarget(_ observation: VNHumanBodyPoseObservation) -> Bool {
        switch targetPose {
        case .O:
            return isOPose(observation)
        case .X:
            return isXPose(observation)
        }
    }
    
    /// Simple “O” pose detection: wrists close together and above head
    private func isOPose(_ obs: VNHumanBodyPoseObservation) -> Bool {
        guard let wristL = try? obs.recognizedPoint(.leftWrist),
              let wristR = try? obs.recognizedPoint(.rightWrist),
              let head = try? obs.recognizedPoint(.nose)
        else { return false }
        
        let closeEnough = hypot(wristL.x - wristR.x, wristL.y - wristR.y) < 0.15
        let aboveHead = wristL.y > head.y && wristR.y > head.y
        
        return wristL.confidence > 0.3 && wristR.confidence > 0.3 && closeEnough && aboveHead
    }
    
    /// Simple “X” pose detection: wrists far apart, ankles far apart
    private func isXPose(_ obs: VNHumanBodyPoseObservation) -> Bool {
        guard let wristL = try? obs.recognizedPoint(.leftWrist),
              let wristR = try? obs.recognizedPoint(.rightWrist),
              let ankleL = try? obs.recognizedPoint(.leftAnkle),
              let ankleR = try? obs.recognizedPoint(.rightAnkle)
        else { return false }
        
        let armSpread = abs(wristL.x - wristR.x) > 0.5
        let legSpread = abs(ankleL.x - ankleR.x) > 0.5
        
        return wristL.confidence > 0.3 &&
               wristR.confidence > 0.3 &&
               ankleL.confidence > 0.3 &&
               ankleR.confidence > 0.3 &&
               armSpread && legSpread
    }
}
