//
//  LockedInApp.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI

@main
struct LockedInApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}




