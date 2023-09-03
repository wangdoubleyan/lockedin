//
//  SettingsView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/28/23.
//

import SwiftUI
import HealthKit
import UserNotifications

class Settings: ObservableObject {
    @AppStorage("isSnapBackOn") var isSnapBackOn = true
    @AppStorage("interval") var interval = 15.0
}

struct SettingsView: View {
    @State private var isHealthAccessGranted = false
    @State private var isNotificationAccessGrated = false
    @State private var selectedDate = Date()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var settings = Settings()
    @State private var healthAuthorizationStatus: HKAuthorizationStatus = .notDetermined
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @ObservedObject private var healthKitManager = HealthKitManager()
    
    let intervals = [5.0, 10.0, 15.0, 20.0, 30.0, 60.0]
    let notify = NotificationManager()
    
    var body: some View {
        ZStack {
            List {
                Section {
                    Toggle(isOn: $settings.isSnapBackOn) {
                        Text("SnapBacks")
                            .foregroundStyle(Color.theme.foreground)
                    }
                    if settings.isSnapBackOn {
                        Picker(selection: $settings.interval) {
                            ForEach(intervals, id: \.self) { interval in
                                Text("\(interval.formatted()) sec").tag(interval)
                            }
                        } label: {
                            Text("Interval")
                                .foregroundStyle(Color.theme.foreground)
                        }
                    }
                } header: {
                    Text("Pause").foregroundStyle(Color.theme.secondary)
                } footer: {
                    Text("SnapBacks help you focus on the present moment by nudging you with visual, audio, and sensory stimuli.")
                        
                }
                
                Section {
                    Toggle(isOn: $isHealthAccessGranted) {
                        Text("Apple Health")
                            .foregroundStyle(Color.theme.foreground)
                    }
                    .onChange(of: isHealthAccessGranted) { oldValue, newValue in
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
                
                Section {
                    Toggle(isOn: $isNotificationAccessGrated) {
                        Text("Daily Reminder")
                            .foregroundStyle(Color.theme.foreground)
                    }
                    .onChange(of: isNotificationAccessGrated) { oldValue, newValue in
                        if newValue == false {
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                        }
                    }
                    if isNotificationAccessGrated {
                        HStack {
                            DatePicker(selection: $selectedDate, displayedComponents: .hourAndMinute) {
                                Text("Time")
                                    .foregroundStyle(Color.theme.foreground)
                            }
                            Button {
                                notify.sendNotification(date: selectedDate, title: "Time to Pause!", body: "Feeling stressed? Complete a short Pause right now.")
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            } label: {
                                Text("Confirm")
                                    .foregroundStyle(Color.theme.foreground)
                            }
                            .buttonStyle(.bordered)
                            .tint(Color.theme.accent)
    
                        }
                    }
                } header: {
                    Text("Notifications")
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
                healthAuthorizationStatus = status
            }
                        
            healthKitAuthorization()
            notificationAuthorization()
        }
    }
    
    private func healthKitAuthorization() {
        switch healthAuthorizationStatus {
        case .notDetermined:
            isHealthAccessGranted = false
        case .sharingDenied:
            isHealthAccessGranted = false
        case .sharingAuthorized:
            isHealthAccessGranted = true
        @unknown default:
            isHealthAccessGranted = false
        }
    }
    
    private func notificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Checking notification status")
            
            switch settings.authorizationStatus {
            case .notDetermined:
                isNotificationAccessGrated = false
            case .authorized:
                isNotificationAccessGrated = true
            case .denied:
                isNotificationAccessGrated = false
            case .ephemeral:
                isNotificationAccessGrated = true
            case .provisional:
                isNotificationAccessGrated = true
            @unknown default:
                isNotificationAccessGrated = false
            }
        }
        
    }
}


#Preview {
    SettingsView()
}
