//
//  PomodoroStatusButton.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 4/24/24.
//

import SwiftUI

struct PomodoroStatusButton: View {
    @ObservedObject var settings = Settings()
    
    var body: some View {
        VStack {
            if settings.selectedItem == "Pomodoro" {
                Button {
                    PomodoroTimerView().switchPomodoroModes()
                } label: {
                    Image(systemName: "forward.fill")
                    Text(settings.isWorkOn ? "Work" : "Break")
                }
                .foregroundStyle(Color.theme.background)
                .font(.headline)
                .bold()
                .padding(10)
                .background(Color.theme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
            }
        }
    }
    
    
}

#Preview {
    PomodoroStatusButton()
}
