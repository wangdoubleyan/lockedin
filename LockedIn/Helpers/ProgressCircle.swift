//
//  ProgressCircle.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 4/23/24.
//

import SwiftUI

struct ProgressCircle: View {
    var stroke = 0.0
    var progress = 0.0
    var opacity = 0.0
    var timerText = "Start"
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: stroke)
                .foregroundStyle(.ultraThinMaterial)
                .animation(.linear(duration: 1), value: stroke)
            
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(Color.theme.primary.opacity(opacity), style: StrokeStyle(lineWidth: 35.0, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270))
                .animation(.easeIn(duration: 3), value: opacity)
                .animation(.linear(duration: 1), value: progress)
            
            Text("\(timerText)")
                .largeTitleTextStyle()
                .contentTransition(.numericText())
                .fontDesign(.monospaced)
        }
    }
}

#Preview {
    ProgressCircle()
}
