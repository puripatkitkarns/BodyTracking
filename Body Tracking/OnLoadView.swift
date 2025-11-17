//
//  OnLoadView.swift
//  Body Tracking
//
//  Created by 677112 on 11/14/25.
//

import SwiftUI

struct LoadingCameraView: View {
    @State private var cameraViewModel = CameraViewModel()
    @State private var poseViewModel = PoseEstimationViewModel()

    var body: some View {
        Group {
            if cameraViewModel.isCameraReady {
                // Camera ready → show game ContentView
                ContentView(
                    cameraViewModel: cameraViewModel,
                    poseViewModel: poseViewModel
                )
            } else {
                // Loading screen
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(2)
                    Text("Loading Camera...")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.yellow)
            }
        }
        .task {
            await cameraViewModel.checkPermission()
            cameraViewModel.delegate = poseViewModel
        }
    }
}
