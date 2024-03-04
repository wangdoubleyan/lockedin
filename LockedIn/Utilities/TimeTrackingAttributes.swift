//
//  TimeTrackingAttributes.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 3/1/24.
//

import Foundation
import ActivityKit

struct TimeTrackingAttributes: ActivityAttributes {
    public typealias TimeTrackingStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var endDate: Date
    }
}
