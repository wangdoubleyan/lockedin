//
//  MindfulPauseApp.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI

@main
struct MindfulPauseApp: App {
    @StateObject private var healthKitManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            SelectView()
                .preferredColorScheme(.dark)
                .onAppear {
                    healthKitManager.requestAuthorization()
                }
        }
    }
}

