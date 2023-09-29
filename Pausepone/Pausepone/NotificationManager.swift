//
//  NotificationManager.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 9/2/23.
//

import Foundation
import UserNotifications

class NotificationManager {
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permission granted!")
            } else if let error = error {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func sendNotification(date: Date, title: String, body: String) {
        var trigger: UNNotificationTrigger?
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        print("Notification set!")
        
    }
}
