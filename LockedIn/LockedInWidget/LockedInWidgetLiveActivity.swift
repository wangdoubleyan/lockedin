//
//  LiveActivityWidgetLiveActivity.swift
//  LiveActivityWidget
//
//  Created by Matsvei Liapich on 3/1/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LockedInWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeTrackingAttributes.self) { context in
            TimeTrackingWidgetView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .dynamicIsland(verticalPlacement: .belowIfTooWide)
                        Text(context.state.endDate, style: .timer)
                            .contentTransition(.numericText())
                            .fontDesign(.monospaced)
                            .font(.title)
                            .bold()
                            .padding(.leading, 150)
                    }
                
                }
                
            } compactLeading: {
                Image(systemName: "brain.head.profile")
                    .frame(width: 45)
            } compactTrailing: {
                Text(context.state.endDate, style: .timer)
                    .frame(width: 45)
                    .contentTransition(.numericText())
                    .fontDesign(.monospaced)
                    .bold()
            } minimal: {
                Image(systemName: "brain.head.profile")
            }
        }
    }
}

struct TimeTrackingWidgetView: View {
    let context: ActivityViewContext<TimeTrackingAttributes>
    
    var body: some View {
        Text(context.state.endDate, style: .relative)
    }
}





