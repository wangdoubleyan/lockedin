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
                DynamicIslandExpandedRegion(.leading) {
                    VStack {
                        Spacer()
                        Image(systemName: "brain.head.profile")
                            .font(.largeTitle)
                            .padding(.bottom, 4)
                    }
                    .frame(maxHeight: .infinity)

                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack {
                        Spacer()
                        Button {
                            //
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                        .buttonBorderShape(.roundedRectangle(radius: 20))
                        .font(.largeTitle)
                        .tint(Color("AccentColor"))
                    }
                    .frame(maxHeight: .infinity)
                }
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Text("Focus")
                            .bold()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    Text(context.state.endDate, style: .timer)
                        .contentTransition(.numericText())
                        .fontDesign(.monospaced)
                        .bold()
                        .font(.title)
                   
                    
                }
                
            } compactLeading: {
                Image(systemName: "brain.head.profile")
            } compactTrailing: {
                let range = Date.now...context.state.endDate
                if Int(context.state.endDate.timeIntervalSinceNow) > 3599 {
                    Text(timerInterval: Date.now...context.state.endDate, pauseTime: range.lowerBound)
                        .contentTransition(.numericText())
                        .fontDesign(.monospaced)
                        .bold()
                        .frame(width: 65)
                } else {
                    Text(timerInterval: Date.now...context.state.endDate, pauseTime: range.lowerBound)
                        .contentTransition(.numericText())
                        .fontDesign(.monospaced)
                        .bold()
                        .frame(width: 45)
                }
                
            } minimal: {
                Image(systemName: "brain.head.profile")
            }
        }
    }
}

struct TimeTrackingWidgetView: View {
    let context: ActivityViewContext<TimeTrackingAttributes>
    
    var body: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .foregroundStyle(.white)
                .font(.title)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Focus")
                        .font(.caption)
                        .bold()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                Text(context.state.endDate, style: .timer)
                    .contentTransition(.numericText())
                    .fontDesign(.monospaced)
                    .bold()
                    .font(.title)
            }
            .foregroundStyle(.white)
            
            Button {
                //
            } label: {
                Image(systemName: "gearshape.fill")
            }
            .buttonBorderShape(.roundedRectangle(radius: 20))
            .font(.largeTitle)
            .tint(Color("AccentColor"))
        }
        .activityBackgroundTint(.black)
    }
}





