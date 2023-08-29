//
//  SettingsView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/28/23.
//

import SwiftUI

class Settings: ObservableObject {
    @AppStorage("isSnapBackOn") var isSnapBackOn = true
}

struct SettingsView: View {
    @StateObject var settings = Settings()
    
    var body: some View {
        List {
            Section {
                Toggle(isOn: $settings.isSnapBackOn) {
                    Text("SnapBacks")
                }
            } header: {
                Text("Timer")
            } footer: {
                Text("SnapBacks help you focus on the present moment by bringing your attention back with visual, audio, and sensory stimuli.")
            }
        }
        .navigationTitle("Settings")
        
    }
}

#Preview {
    SettingsView()
}
