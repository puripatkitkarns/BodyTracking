//
//  BodyConnection.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import SwiftUI
import Vision
import AVFoundation
import Observation

@Observable
class PoseEstimationViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var detectedBodyParts: [HumanBodyPoseObservation.JointName: CGPoint] = [:]
    var bodyConnections: [BodyConnection] = []
    
    var shapeDetected: AlphabetPose? = nil
    var targetPose: AlphabetPose = .O
    
    var score: Int = 0
    var timeRemaining: Int = gameTime
    private var timer: Timer?
    private var lastMatchTime: Date = .now
    var gameOver: Bool = false
    var isGameRunning: Bool = false
    
    private var audioPlayer: AVAudioPlayer?

    override init() {
        super.init()
        setupBodyConnections()
        loadSuccessSound()
    }

    // Start
    func startGame() {
        clearGame()
        isGameRunning = true
        shapeDetected = nil
        targetPose = AlphabetPose.allCases.randomElement()!
        lastMatchTime = .now

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { time in
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                self.isGameRunning = false
                self.gameOver = true
                time.invalidate()
            }
        }
    }
    
    func clearGame() {
        gameOver = false
        score = 0
        timeRemaining = gameTime
    }

    // Camera Frame Processing
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection)
    {
        Task {
            let detectedPoints = await processFrame(sampleBuffer)

            DispatchQueue.main.async {
                if let points = detectedPoints, !points.isEmpty,
                   self.isBodyInsideXZone(points: points, xRange: activeXRange) {

                    // Only track person inside horizontal zone
                    self.detectedBodyParts = points
                    self.shapeDetected = self.classifyShape(from: points)

                    // Game logic
                    guard self.isGameRunning else { return }
                    if let current = self.shapeDetected, current == self.targetPose {
                        let now = Date()
                        if now.timeIntervalSince(self.lastMatchTime) > 0.8 {
                            self.score += 1
                            self.playSuccessSound()
                            self.lastMatchTime = now
                            self.targetPose = AlphabetPose.allCases.randomElement()!
                        }
                    }
                } else {
                    // Person outside zone → ignore
                    self.detectedBodyParts = [:]
                    self.shapeDetected = nil
                }
            }
        }
    }
    
    func isBodyInsideXZone(points: [HumanBodyPoseObservation.JointName: CGPoint], xRange: ClosedRange<CGFloat>) -> Bool {
        guard let ls = points[.leftShoulder],
              let rs = points[.rightShoulder],
              let lh = points[.leftHip],
              let rh = points[.rightHip] else { return false }

        let keyPoints = [ls, rs, lh, rh]

        // Only track if ALL key points are inside the X range
        return keyPoints.allSatisfy { xRange.contains($0.x) }
    }

    // Body Connections
    private func setupBodyConnections() {
        bodyConnections = [
            BodyConnection(from: .nose, to: .neck),
            BodyConnection(from: .neck, to: .rightShoulder),
            BodyConnection(from: .neck, to: .leftShoulder),
            BodyConnection(from: .rightShoulder, to: .rightHip),
            BodyConnection(from: .leftShoulder, to: .leftHip),
            BodyConnection(from: .rightHip, to: .leftHip),
            BodyConnection(from: .rightShoulder, to: .rightElbow),
            BodyConnection(from: .rightElbow, to: .rightWrist),
            BodyConnection(from: .leftShoulder, to: .leftElbow),
            BodyConnection(from: .leftElbow, to: .leftWrist),
            BodyConnection(from: .rightHip, to: .rightKnee),
            BodyConnection(from: .rightKnee, to: .rightAnkle),
            BodyConnection(from: .leftHip, to: .leftKnee),
            BodyConnection(from: .leftKnee, to: .leftAnkle)
        ]
    }

    // Pose Classification
    private func classifyShape(from points: [HumanBodyPoseObservation.JointName: CGPoint]) -> AlphabetPose? {
        // X detection
        if let leftWrist = points[.leftWrist],
           let rightWrist = points[.rightWrist],
           let leftShoulder = points[.leftShoulder],
           let rightShoulder = points[.rightShoulder] {

            let chestY = (leftShoulder.y + rightShoulder.y) / 2
            let wristsNearChest = abs(leftWrist.y - chestY) < 0.1 && abs(rightWrist.y - chestY) < 0.1
            let crossed = leftWrist.x > rightWrist.x
            let wristDistance = hypot(leftWrist.x - rightWrist.x, leftWrist.y - rightWrist.y)
            let wristsClose = wristDistance < 0.15

            if wristsNearChest && crossed && wristsClose {
                return .X
            }
        }

        // O detection
        if let leftWrist = points[.leftWrist],
           let rightWrist = points[.rightWrist],
           let leftElbow = points[.leftElbow],
           let rightElbow = points[.rightElbow],
           let leftShoulder = points[.leftShoulder],
           let rightShoulder = points[.rightShoulder] {

            let wristsMidY = (leftWrist.y + rightWrist.y) / 2
            let shouldersY = min(leftShoulder.y, rightShoulder.y)
            let wristDistance = hypot(leftWrist.x - rightWrist.x,
                                      leftWrist.y - rightWrist.y)

            if wristsMidY < shouldersY && wristDistance < 0.2 {
                return .O
            }
        }
        
        // V detection
        if let leftWrist = points[.leftWrist],
           let rightWrist = points[.rightWrist],
           let leftElbow = points[.leftElbow],
           let rightElbow = points[.rightElbow],
           let leftShoulder = points[.leftShoulder],
           let rightShoulder = points[.rightShoulder] {

            // Arm raised check (wrist above elbow, elbow above shoulder)
            let leftArmUp  = leftWrist.y < leftElbow.y && leftElbow.y < leftShoulder.y
            let rightArmUp = rightWrist.y < rightElbow.y && rightElbow.y < rightShoulder.y

            // Normalize wrist spread to shoulder width
            let shoulderWidth = abs(leftShoulder.x - rightShoulder.x)
            let wristSpread = abs(leftWrist.x - rightWrist.x)
            let spreadEnough = wristSpread >= shoulderWidth * 0.6  // flexible threshold

            if leftArmUp && rightArmUp && spreadEnough {
                return .V
            }
        }
        
        // I
        if let leftWrist = points[.leftWrist],
           let rightWrist = points[.rightWrist],
           let leftElbow = points[.leftElbow],
           let rightElbow = points[.rightElbow],
           let leftShoulder = points[.leftShoulder],
           let rightShoulder = points[.rightShoulder],
           let leftHip = points[.leftHip],
           let rightHip = points[.rightHip] {

            // Arms close to body (x-coordinates near shoulders)
            let leftArmClose = abs(leftWrist.x - leftShoulder.x) < 0.1 && abs(leftElbow.x - leftShoulder.x) < 0.1
            let rightArmClose = abs(rightWrist.x - rightShoulder.x) < 0.1 && abs(rightElbow.x - rightShoulder.x) < 0.1

            // Body roughly vertical
            let shouldersAligned = abs(leftShoulder.y - rightShoulder.y) < 0.1
            let hipsAligned = abs(leftHip.y - rightHip.y) < 0.1

            if leftArmClose && rightArmClose && shouldersAligned && hipsAligned {
                return .I
            }
        }

        return nil
    }

    // Body Point Extraction
    func processFrame(_ sampleBuffer: CMSampleBuffer) async
        -> [HumanBodyPoseObservation.JointName: CGPoint]?
    {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }

        let request = DetectHumanBodyPoseRequest()

        do {
            let results = try await request.perform(on: imageBuffer, orientation: .none)
            if let observation = results.first {
                return extractPoints(from: observation)
            }
        } catch {
            print("Error processing frame: \(error)")
        }

        return nil
    }

    private func extractPoints(from observation: HumanBodyPoseObservation)
        -> [HumanBodyPoseObservation.JointName: CGPoint]
    {
        var detectedPoints: [HumanBodyPoseObservation.JointName: CGPoint] = [:]
        let groups: [HumanBodyPoseObservation.PoseJointsGroupName] =
            [.face, .torso, .leftArm, .rightArm, .leftLeg, .rightLeg]

        for group in groups {
            for (name, joint) in observation.allJoints(in: group) {
                if joint.confidence > 0.5 {
                    let point = joint.location.verticallyFlipped().cgPoint
                    detectedPoints[name] = point
                }
            }
        }

        return detectedPoints
    }
    
    private func loadSuccessSound() {
        guard let url = Bundle.main.url(forResource: "success", withExtension: "mp3") else {
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to load sound:", error)
        }
    }
    
    private func playSuccessSound() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
}
