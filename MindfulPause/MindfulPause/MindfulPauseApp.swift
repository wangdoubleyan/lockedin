//
//  MindfulPauseApp.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI

@main
struct MindfulPauseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            SelectView()
                .preferredColorScheme(.dark)
                .onAppear {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                    AppDelegate.orientationLock = .portrait
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
         
    static var orientationLock = UIInterfaceOrientationMask.all
 
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
