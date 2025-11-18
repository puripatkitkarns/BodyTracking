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

// Tutorial
let tutorials: [(image: String, title: String, text: String)] = [
    ("tutorial1", "Match the Pose", "อยู่บริเวณกลางจอ รอให้กล้องตรวจจับร่างกาย กดปุ่มเพื่อเริ่มเกม"),
    ("O", "Be Quick", "ทำท่าทางตามตัวอักษรที่ขึ้นมาเพื่อเก็บแต้ม ถ้าทำถูกต้องจะได้รับ 1 คะแนน"),
    ("O", "O Pose", "ทำแขนเป็นวงกลมไว้เหนือศีรษะ"),
    ("V", "V Pose", "กางแขนเป็นรูปตัว V"),
    ("X", "X Pose", "ทำแขนไขว้กันไว้บริเวณอก"),
    ("I", "I Pose", "ยืนนิ่งตรง ไม่ต้องชูแขน"),
    ("app", "Earn Points", "เก็บแต้ม ลุ้นรับรางวัล")
]
