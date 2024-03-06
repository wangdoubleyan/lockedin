//
//  LiveActivitiesManager.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 3/4/24.
//

import Foundation
import ActivityKit
import SwiftUI

class LiveActivitiesManager {
    class func startLiveActivity(activity: Activity<TimeTrackingAttributes>?, expectedEndDate: Date) {
        let attributes = TimeTrackingAttributes()
        let state = TimeTrackingAttributes.ContentState(endDate: expectedEndDate)
        let activityContent = ActivityContent(state: state, staleDate: expectedEndDate)

        
        // Update the method to use request(attributes:content:pushType:) instead
        _ = try? Activity<TimeTrackingAttributes>.request(attributes: attributes, content: activityContent, pushType: nil)
        
        print(Int(expectedEndDate.timeIntervalSinceNow))
        
    }

    class func stopLiveActivity() {
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            for activity in Activity<TimeTrackingAttributes>.activities {
                print("Terminating live activity \(activity.id)!")
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
}
