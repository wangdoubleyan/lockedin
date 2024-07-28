//
//  PomodoroCounterButton.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 4/24/24.
//

import SwiftUI

struct PomodoroCounterButton: View {
    var body: some View {
        @ObservedObject var time = Time()
        
        VStack {
            Text("\(time.pomodoroNumberOfIntervals - time.pomodoroIntervalCounter + 1) left")
                .foregroundStyle(Color.theme.foreground)
                .font(.headline)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
            
        }
    }
}

#Preview {
    PomodoroCounterButton()
}
