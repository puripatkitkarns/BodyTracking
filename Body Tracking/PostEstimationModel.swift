//
//  PostEstimationModel.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import Foundation
import Vision

let gameTime = 10
let videoRotationAngle: CGFloat = 180

struct BodyConnection: Identifiable {
    let id = UUID()
    let from: HumanBodyPoseObservation.JointName
    let to: HumanBodyPoseObservation.JointName
}

enum AlphabetPose: String, CaseIterable {
    case X
    case O
    case V
    case I
}

// Normalized coordinates (0 = left/top, 1 = right/bottom)
struct TrackingBoundary {
    let xRange: ClosedRange<CGFloat>
    let yRange: ClosedRange<CGFloat>
    
    func contains(_ point: CGPoint) -> Bool {
        xRange.contains(point.x) && yRange.contains(point.y)
    }
}

// Normalized coordinates: 0 = left, 1 = right
let activeXRange: ClosedRange<CGFloat> = 0.25...0.75  // 25%-75% of width
