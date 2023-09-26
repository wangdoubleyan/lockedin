//
//  SettingsView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/28/23.
//

import SwiftUI
import HealthKit
import UserNotifications

extension Date: RawRepresentable {
    public var rawValue: String {
        self.timeIntervalSinceReferenceDate.description
    }
    
    public init?(rawValue: String) {
        self = Date(timeIntervalSinceReferenceDate: Double(rawValue) ?? 0.0)
    }
}

class Settings: ObservableObject {
    @AppStorage("isSnapBackOn") var isSnapBackOn = true
    @AppStorage("isMusicOn") var isMusicOn = true
    @AppStorage("backgroundMusic") var backgroundMusic = "Dream"
    @AppStorage("interval") var interval = 15.0
}

struct SettingsView: View {
    @State private var isHealthAccessGranted = false
    @State private var isNotificationAccessGranted = false
    @State private var isNotificationSet = false
    
    @AppStorage("selectedDate") var selectedDate = Date()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var settings = Settings()
    @State private var healthAuthorizationStatus: HKAuthorizationStatus = .notDetermined
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @StateObject private var healthKitManager = HealthKitManager()
    
    let intervals = [5.0, 10.0, 15.0, 30.0, 60.0]
    let backgroundMusicList = ["Campfire", "Dream", "Rain", "Stream"]
    let notify = NotificationManager()
    
    var body: some View {
        ZStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "music.note")
                        Toggle(isOn: $settings.isMusicOn) {
                            Text("Music")
                                .foregroundStyle(Color.theme.foreground)
                        }
                    }
                    if settings.isMusicOn {
                        Picker(selection: $settings.backgroundMusic) {
                            ForEach(backgroundMusicList, id: \.self) { list in
                                Text(list).tag(list)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Track")

                                    .foregroundStyle(Color.theme.foreground)
                            }
                        }
                    }
                } header: {
                    Text("Background").foregroundStyle(Color.theme.secondary)
                }

                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                )
                .listRowSeparator(.hidden)

                Section {
                    HStack {
                        Image(systemName: "alarm.fill")
                        Toggle(isOn: $settings.isSnapBackOn) {
                            Text("SnapBacks")
                                .foregroundStyle(Color.theme.foreground)
                        }
                    }
                    if settings.isSnapBackOn {
                        Picker(selection: $settings.interval) {
                            ForEach(intervals, id: \.self) { interval in
                                Text("\(interval.formatted()) sec").tag(interval)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "clock.fill")
                                Text("Interval")

                                    .foregroundStyle(Color.theme.foreground)
                            }
                        }
                    }
                } header: {
                    Text("Pause").foregroundStyle(Color.theme.secondary)
                } footer: {
                    Text("SnapBacks help you focus on the present moment by nudging you with visual, audio, and sensory stimuli.")
                    
                }

                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                        Toggle(isOn: $isHealthAccessGranted) {
                            Text("Apple Health")
                                .foregroundStyle(Color.theme.foreground)
                        }
                        .onChange(of: isHealthAccessGranted) { newValue in
                            if newValue == true {
                                healthKitManager.requestAuthorization()
                            }
                        }
                    }
                } header: {
                    Text("Connect")
                } footer: {
                    Text("Enable Mindful Moments by going to Settings > Health > Data Access & Devices > MindfulPause.")
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                )
                
                Section {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                        Toggle(isOn: $isNotificationAccessGranted) {
                            Text("Daily Reminder")
                                .foregroundStyle(Color.theme.foreground)
                        }
                        .onChange(of: isNotificationAccessGranted) { newValue in
                            if newValue {
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    if success {
                                        print("All set!")
                                    } else if let error = error {
                                        print(error.localizedDescription)
                                    }
                                }
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                isNotificationSet = false
                            }
                        }
                    }
                    if isNotificationAccessGranted {
                        HStack {
                            Image(systemName: "deskclock.fill")
                            DatePicker(selection: $selectedDate, displayedComponents: .hourAndMinute) {
                                HStack {
                                    Text("When?")
                                        .foregroundStyle(Color.theme.foreground)
                                    
                                    Spacer()
                                    Button("Set") {
                                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                        notify.sendNotification(date: selectedDate, title: "⏸️ Time to Pause!", body: "How about a quick Pause right now?")
                                        print(selectedDate)
                                        isNotificationSet = true
                                    }
                                    .foregroundStyle(Color.theme.foreground)
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    if isNotificationSet {
                        Text("You will be reminded to Pause daiy at \(selectedDate.formatted(.dateTime.hour().minute())).")
                    }
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                        Link("Credit", destination: URL(string: "https://github.com/matsveil/mindful-pause/blob/main/CREDIT.md")!)
                            .foregroundStyle(Color.theme.foreground)
                    }
                    HStack {
                        Image(systemName: "curlybraces.square.fill")
                        Link("Open Source", destination: URL(string: "https://github.com/matsveil/mindful-pause/blob/main/LICENSE")!)
                            .foregroundStyle(Color.theme.foreground)
                    }
                } header: {
                    Text("Legal")
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Color.theme.secondary.opacity(0.1))
                        .padding(2)
                     
                )
                .listRowSeparator(.hidden)
            }
            .environment(\.defaultMinListRowHeight, 60)
            .tint(Color.theme.accent)
            .background(Color.theme.background)
            .foregroundStyle(Color.theme.secondary)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    } label: {
                        Text(Image(systemName: "arrow.uturn.backward.circle.fill"))
                            .font(.system(size: 35))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(Color.theme.secondary.opacity(0.8))
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Settings")
                            .fontDesign(.rounded)
                            .font(.title2)
                            .bold()
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
            
            print(selectedDate)
            
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
                isNotificationAccessGranted = false
            case .authorized:
                isNotificationAccessGranted = true
            case .denied:
                isNotificationAccessGranted = false
            case .ephemeral:
                isNotificationAccessGranted = true
            case .provisional:
                isNotificationAccessGranted = true
            @unknown default:
                isNotificationAccessGranted = false
            }
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
