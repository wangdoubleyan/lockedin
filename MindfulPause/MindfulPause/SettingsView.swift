//
//  SettingsView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/28/23.
//

import SwiftUI

class Settings: ObservableObject {
    @AppStorage("isSnapBackOn") var isSnapBackOn = true
    @AppStorage("interval") var interval = 15.0
}

struct SettingsView: View {
    @StateObject var settings = Settings()
    let intervals = [5.0, 10.0, 15.0, 20.0, 30.0, 60.0]
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            List {
                Section {
                    Toggle(isOn: $settings.isSnapBackOn) {
                        Text("SnapBacks")
                    }
                    Picker("SnapBack Interval", selection: $settings.interval) {
                        ForEach(intervals, id: \.self) { interval in
                            Text("\(interval.formatted()) sec").tag(interval)
                        }
                    }
                } header: {
                    Text("Timer")
                } footer: {
                    Text("SnapBacks help you focus on the present moment by nudging you with visual, audio, and sensory stimuli.")
                }
            }
            .tint(Color.theme.accent)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
