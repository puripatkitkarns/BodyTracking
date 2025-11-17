//
//  PoseOverlayView.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import SwiftUI
import AVFoundation
import Vision

struct PoseOverlayView: View {
    let bodyParts: [HumanBodyPoseObservation.JointName: CGPoint]
    let connections: [BodyConnection]
    
    var isCorrectPose: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !bodyParts.isEmpty {
                    // Draw Bones (lines)
                    ForEach(connections) { connection in
                        if let fromPoint = bodyParts[connection.from],
                           let toPoint = bodyParts[connection.to] {
                            
                            let start = CGPoint(
                                x: fromPoint.x * geometry.size.width,
                                y: fromPoint.y * geometry.size.height
                            )
                            let end = CGPoint(
                                x: toPoint.x * geometry.size.width,
                                y: toPoint.y * geometry.size.height
                            )
                            
                            Path { path in
                                path.move(to: start)
                                path.addLine(to: end)
                            }
                            .stroke(
                                isCorrectPose ? Color.green : Color.yellow,
                                lineWidth: 10
                            )
                            .shadow(color: isCorrectPose ? .green : .clear, radius: 100)
                        }
                    }
                    
                    // Draw Joints (dots)
                    ForEach(Array(bodyParts.keys), id: \.self) { jointName in
                        if let point = bodyParts[jointName] {
                            
                            let pos = CGPoint(
                                x: point.x * geometry.size.width,
                                y: point.y * geometry.size.height
                            )
                            
                            Circle()
                                .fill(isCorrectPose ? Color.green : Color.white)
                                .frame(width: 8, height: 8)
                                .shadow(color: isCorrectPose ? .green : .clear, radius: 6)
                                .position(pos)
                        }
                    }
                }
            }
            //.animation(.easeInOut(duration: 0.15), value: isCorrectPose)
        }
    }
}
