//
//  SettingsView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/28/23.
//

import SwiftUI
import HealthKit
import UserNotifications

struct SettingsView: View {
    @State private var isHealthAccessGranted = false
    @State private var isNotificationAccessGranted = false
    @State private var isNotificationSet = false
    
    @AppStorage("selectedDate") var selectedDate = Date()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var settings = Settings()
    @ObservedObject var time = Time()
    @State private var healthAuthorizationStatus: HKAuthorizationStatus = .notDetermined
    @State private var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @StateObject private var healthKitManager = HealthKitManager()
    
    let intervals = [15.0, 30.0, 60.0]
    static let backgroundMusicList = ["Brown Noise", "Campfire", "Focus", "Meditation", "Piano", "Rain", "Relax", "Sleep", "Stream"]
    let notify = NotificationManager()
    
    var body: some View {
        ZStack {
            BackgroundView()
            List {
                Section {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .frame(width: 30, height: 30)
                            .font(.title3)
                            
                        Toggle(isOn: $settings.isMusicOn) {
                            Text("Music")
                                .smallTitleTextStyle()
                        }
                    }
                    if settings.isMusicOn {
                        Picker(selection: $settings.backgroundMusic) {
                            ForEach(SettingsView.backgroundMusicList, id: \.self) { list in
                                Text(list)
                                    .tag(list)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "music.note")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.theme.secondary)
                                    .font(.title3)
                                Text("Track")
                                    .smallTitleTextStyle()
                            }
                        }
                    }
                } header: {
                    Text("Background")
                        .captionTextStyle()
                }

                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                        .padding(2)
                )
                .listRowSeparator(.hidden)

                Section {
                    HStack {
                        Image(systemName: "bell.badge.waveform.fill")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title3)
                        Toggle(isOn: $settings.isSnapOn) {
                            Text("Snaps")
                                .smallTitleTextStyle()
                        }
                    }
                    if settings.isSnapOn {
                        Picker(selection: $settings.snapInterval) {
                            ForEach(intervals, id: \.self) { interval in
                                Text("\(interval.formatted()) sec")
                                    .tag(interval)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.2.circlepath")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.theme.secondary)
                                    .font(.title3)
                                Text("Interval")
                                    .smallTitleTextStyle()
                            }
                        }
                    }
                } header: {
                    Text("Focus")
                        .captionTextStyle()
                } footer: {
                    Text("Snaps help you focus on the present moment by nudging you with visual, audio, and sensory stimuli.")
                        .captionTextStyle()
                    
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                        .padding(2)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Picker(selection: $time.pomodoroNumberOfIntervals) {
                            ForEach(2...4, id: \.self) { i in
                                Text("\(i)")
                                    .tag(i)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "timer")
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(Color.theme.secondary)
                                    .font(.title3)
                                Text("Number of Intervals")
                                    .smallTitleTextStyle()
                            }
                        }
                        
                    }
                } header: {
                    Text("Pomodoro")
                        .captionTextStyle()
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                        .padding(2)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Image(systemName: "lungs.fill")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title3)
                        Toggle(isOn: $settings.isBreathOn) {
                            Text("Breathing")
                                .smallTitleTextStyle()
                        }
                    }
                } header: {
                    Text("Breathe")
                        .captionTextStyle()
                }

                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                        .padding(2)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Image(systemName: "heart.fill")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title3)

                        Toggle(isOn: $isHealthAccessGranted) {
                            Text("Apple Health")
                                .smallTitleTextStyle()
                        }
                        .onChange(of: isHealthAccessGranted) { newValue in
                            if newValue == true {
                                healthKitManager.requestAuthorization()
                            }
                        }
                    }
                } header: {
                    Text("Connect")
                        .captionTextStyle()
                } footer: {
                    Text("Enable Mindful Minutes by going to Settings > Health > Data Access & Devices > LockedIn.")
                        .captionTextStyle()
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                        .padding(2)
                )
                
                Section {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title3)

                        Toggle(isOn: $isNotificationAccessGranted) {
                            Text("Daily Reminder")
                                .smallTitleTextStyle()
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
                            Image(systemName: "clock.fill")
                                .frame(width: 30, height: 30)
                                .foregroundStyle(Color.theme.secondary)
                                .font(.title3)

                            DatePicker(selection: $selectedDate, displayedComponents: .hourAndMinute) {
                                HStack {
                                    Text("When?")
                                        .smallTitleTextStyle()
                                    
                                    Spacer()
                                    Button {
                                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                                        notify.sendNotification(date: selectedDate, title: "Start Focus Session Now", body: "It's time to do what needs to be done!")
                                        print(selectedDate)
                                        isNotificationSet = true
                                    } label: {
                                        Text("Set")
                                            .foregroundStyle(Color.theme.background)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                        .captionTextStyle()
                } footer: {
                    if isNotificationSet {
                        Text("You will be reminded to focus daiy at \(selectedDate.formatted(.dateTime.hour().minute())).")
                            .captionTextStyle()
                    }
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                        .padding(2)
                )
                .listRowSeparator(.hidden)
                
                Section {
                    HStack {
                        Image(systemName: "quote.opening")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title3)

                        Link("Credit", destination: URL(string: "https://github.com/matsveil/lockedin/blob/main/CREDIT.md")!)
                            .foregroundColor(Color.theme.foreground)
                            .font(.title3)
                            .bold()
                    }
                    HStack {
                        Image(systemName: "lock.open.fill")
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.theme.secondary)
                            .font(.title3)
                        
                        Link("Open Source", destination: URL(string: "https://github.com/matsveil/lockedin/blob/main/LICENSE")!)
                            .foregroundColor(Color.theme.foreground)
                            .font(.title3)
                            .bold()
                    }
                } header: {
                    Text("Legal")
                        .captionTextStyle()
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20.0, style: .continuous)
                        .fill(Material.ultraThinMaterial)
                        .padding(2)
                )
                .listRowSeparator(.hidden)
            }
            .navigationTitle("Settings")
            .toolbar(.hidden, for: .tabBar)
            .environment(\.defaultMinListRowHeight, 60)
            .tint(Color.theme.accent)
            .foregroundStyle(Color.theme.secondary)
            .scrollContentBackground(.hidden)
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

#Preview {
    SettingsView()
}

