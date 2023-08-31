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
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var settings = Settings()
    let intervals = [5.0, 10.0, 15.0, 20.0, 30.0, 60.0]
    
    var body: some View {
        ZStack {
            List {
                Section {
                    Toggle(isOn: $settings.isSnapBackOn) {
                        Text("SnapBacks")
                            .font(.headline)
                    }
                    Picker("SnapBack Interval", selection: $settings.interval) {
                        ForEach(intervals, id: \.self) { interval in
                            Text("\(interval.formatted()) sec").tag(interval)
                        }
                    }
                    .font(.headline)
                } header: {
                    Text("Pause timer").foregroundStyle(Color.theme.secondary)
                } footer: {
                    Text("SnapBacks help you focus on the present moment by nudging you with visual, audio, and sensory stimuli.")
                        .foregroundStyle(Color.theme.secondary)
                }
                .listRowBackground(Color.theme.surface)
            }
            .background(Color.theme.background)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrowshape.backward.fill")
                        Text("Back")
                            .font(.headline)
                    }
                }
            }
            ToolbarItem(placement: .principal) { // <3>
                VStack {
                    Text("Settings")
                        .bold()
                        .fontDesign(.rounded)
                        .font(.title)
                }
            }
                    
        }
    }
}

#Preview {
    SettingsView()
}
