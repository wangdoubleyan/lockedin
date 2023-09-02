//
//  SettingsView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/28/23.
//

import SwiftUI
import HealthKit

class Settings: ObservableObject {
    @AppStorage("isSnapBackOn") var isSnapBackOn = true
    @AppStorage("interval") var interval = 15.0
}

struct SettingsView: View {
    @State private var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @ObservedObject private var healthKitManager = HealthKitManager()
    @State private var isAccessGranted = false
    
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
                            .foregroundStyle(Color.theme.foreground)
                    }
                    Picker(selection: $settings.interval) {
                        ForEach(intervals, id: \.self) { interval in
                            Text("\(interval.formatted()) sec").tag(interval)
                        }
                    } label: {
                        Text("SnapBack Interval")
                            .foregroundStyle(Color.theme.foreground)
                    }
                } header: {
                    Text("Pause timer").foregroundStyle(Color.theme.secondary)
                } footer: {
                    Text("SnapBacks help you focus on the present moment by nudging you with visual, audio, and sensory stimuli.")
                        
                }
                
                Section {
                    Toggle(isOn: $isAccessGranted) {
                        Text("Apple Health")
                            .foregroundStyle(Color.theme.foreground)
                    }
                    .onChange(of: isAccessGranted) { oldValue, newValue in
                        if newValue == true {
                            DispatchQueue.main.async {
                                healthKitManager.requestAuthorization()
                            }
                        }
                    }
                } header: {
                    Text("Connect")
                } footer: {
                    Text("Enable Mindful Moments by going to Settings > Health > Data Access & Devices > MindfulPause.")
                }
                
                
                
            }
            .background(Color.theme.background)
            .foregroundStyle(Color.theme.secondary)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "arrowshape.backward.fill")
                            Text("Back")
                                .font(.headline)
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Settings")
                            .bold()
                            .fontDesign(.rounded)
                            .font(.title)
                    }
                }
                
            }
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            healthKitManager.checkAuthorizationStatus { status in
                authorizationStatus = status
            }
            
            authorization()
        }
    }
    
    private func authorization() {
        switch authorizationStatus {
        case .notDetermined:
            isAccessGranted = false
        case .sharingDenied:
            isAccessGranted = false
        case .sharingAuthorized:
            isAccessGranted = true
        @unknown default:
            isAccessGranted = false
        }
    }
}


#Preview {
    SettingsView()
}
