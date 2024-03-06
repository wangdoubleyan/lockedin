//
//  SceneDelegate.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 3/4/24.
//

import Foundation
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        print("SceneDelegate is connected!")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // This method is called when the scene is about to be terminated.
        print("App terminated!")
        LiveActivitiesManager.stopLiveActivity()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // This method is called when the scene becomes active (foreground).
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // This method is called when the scene will resign its active status.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // This method is called when the scene is about to enter the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // This method is called when the scene enters the background.
    }
}
