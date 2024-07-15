//
//  TimerView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import StoreKit
import ActivityKit

struct TimerView: View {
    @ObservedObject private var healthKitManager = HealthKitManager()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.requestReview) var requestReview
    @Environment(\.scenePhase) var scenePhase
    
    @ObservedObject var time = Time()
    @ObservedObject var settings = Settings()
    @ObservedObject var review = Review()
    
//    Timer ring progress
    @State private var progress = 0.0
    
//    Used for animation
    @State private var stroke = 0.0
    @State private var opacity = 0.0
    
    @State private var flash = 0.0
    @State private var timerCounter = "Start"
    @State private var initialTime = 0
    
    @State private var showingEndAlert = false
    
    @State private var startDate = Date()
        
//    Calculated when user exits timer
    @State private var actualEndDate = Date()

    @State private var pauseTime = Date()

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var snapTimer = Timer.publish(every: Settings().snapInterval, on: .main, in: .common).autoconnect()
    
    @State var activity: Activity<TimeTrackingAttributes>? = nil
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                VStack {
                    ZStack {
                        ProgressCircle(stroke: stroke, progress: progress, opacity: opacity, timerText: timerCounter)
                        
                        PomodoroStatusButton()
                            .offset(y: -60)
                        
                        PomodoroCounterButton()
                            .offset(y: 60)
                        
                        .onAppear {
                            startDate = Date()
                            
                            //            Makes sure that a timer of 0 is not possible
                            if time.hr == 0 && time.min == 0 {
                                time.min = 1
                            }
                            
                            settings.selectedItem == "Simple" ? start(hours: time.hr, minutes: Int(time.min)) : start(hours: 0, minutes: time.pomodoroWork)
                        }
                        
                        .onReceive(timer) { time in
                            updateCountdown()
                        }
                        
                        .onReceive(snapTimer) { time in
                            snap()
                        }
                    }
                }
            }
            .padding(.vertical, 155)
            .padding(.horizontal, 40)
            
            
            VStack {
                Spacer()
                
                MediaControlButton()
            }
            .padding()
            .padding(.bottom, 25)
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEndAlert = true
                } label: {
                    Text(Image(systemName: "stop.circle.fill"))
                        .font(.system(size: 35))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.theme.primary)
                }
                .alert("End This Focus Session?", isPresented: $showingEndAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("End", role: .destructive) { end() }
                }
                
                        
            }
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Focus")
                        .mediumTitleTextStyle()
                }
            }
        }
    }
    

    func snap() {
        if settings.isSnapOn {
            DispatchQueue.global(qos: .userInteractive).async {
                SoundManager.instance.playSound(sound: "SnapSound")
                
            }
            
            haptic()
            
            flash = 1
            
            withAnimation(.easeOut.delay(0.5)) {
                flash = 0.0
            }
        }
    }
    
    func vibrate() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    func haptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    
//    Calculates the timer duration
    func start(hours: Int, minutes: Int) {
        progress = 0.0
        initialTime = hours * 60 + minutes
        settings.expectedEndDate = Date()
        settings.expectedEndDate = Calendar.current.date(byAdding: .minute, value: initialTime, to: settings.expectedEndDate)!
        UIApplication.shared.isIdleTimerDisabled = true
        vibrate()
        stroke = 45.0
        opacity = 1
        DispatchQueue.global(qos: .userInteractive).async {
            SoundManager.instance.playSound(sound: "Sound")
            if settings.isWorkOn {
                SoundManager.instance.playMusic(music: settings.backgroundMusic)
            } else {
                SoundManager.instance.musicPlayer.stop()
            }
        }
        
        LiveActivitiesManager.startLiveActivity(activity: activity, expectedEndDate: settings.expectedEndDate)
    }
    
    
    func updateCountdown() {
        let now = Date()
        let diff = settings.expectedEndDate.timeIntervalSince(now)
        
        if diff <= 0 {
            if settings.selectedItem == "Simple" {
                end()
            } else {
                switchPomodoroModes()
            }
        } else {
            progress += 1.0 / Double(initialTime * 60)
            
            let hours = Int(diff / 3600)
            let minutes = Int((diff / 60).truncatingRemainder(dividingBy: 60))
            let seconds = Int(diff.truncatingRemainder(dividingBy: 60))
                        
            withAnimation {
                if hours == 0 && minutes == 0 {
                    timerCounter = String(format: "%02d", seconds)
                } else if hours == 0 {
                    timerCounter = String(format: "%d:%02d", minutes, seconds)
                } else {
                    timerCounter = String(format: "%d:%d:%02d", hours, minutes, seconds)
                }
            }
        }
        
    }

    func end() {
        progress = 100
        LiveActivitiesManager.stopLiveActivity()
        
        SoundManager.instance.fadeMusic()
        actualEndDate = Date()
        timerCounter = "Finish"
        SoundManager.instance.playSound(sound: "Sound")
        timer.upstream.connect().cancel()
        snapTimer.upstream.connect().cancel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            UIApplication.shared.isIdleTimerDisabled = false
                        
            SoundManager.instance.musicPlayer.stop()
            
            healthKitManager.saveMindfulMinutes(start: startDate, end: actualEndDate)
            
            dismiss()
            presentationMode.wrappedValue.dismiss()
        }
        
        review.cycleCount += 1
        if review.cycleCount % 15 == 0 {
            requestReview()
        }
    }
    
    
    
    func pauseTimer() {
        pauseTime = Date()
        timer.upstream.connect().cancel()
        snapTimer.upstream.connect().cancel()
        settings.isTimerPaused.toggle()
        SoundManager.instance.fadeMusic()
        LiveActivitiesManager.stopLiveActivity()
    }
    
    func resumeTimer() {
        let elapsedTime = Date().timeIntervalSince(pauseTime)
        
//        1.5 added seconds are necessary to account for a lost second if paused at the end of a second
        settings.expectedEndDate = settings.expectedEndDate + elapsedTime + 1.5
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        snapTimer = Timer.publish(every: settings.snapInterval, on: .main, in: .common).autoconnect()
        settings.isTimerPaused.toggle()
            
        if settings.isMusicOn {
            SoundManager.instance.musicPlayer.setVolume(0.0, fadeDuration: 0.0)
            SoundManager.instance.playMusic(music: settings.backgroundMusic)
            SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: settings.musicFadeTime)
        }
        LiveActivitiesManager.startLiveActivity(activity: activity, expectedEndDate: settings.expectedEndDate)
    }
    
    func switchPomodoroModes() {
        LiveActivitiesManager.stopLiveActivity()
        
        if settings.isWorkOn {
            if time.pomodoroIntervalCounter == time.pomodoroNumberOfIntervals {
                progress = 100.0
                time.pomodoroIntervalCounter += 1
                end()
            } else {
                start(hours: 0, minutes: time.pomodoroBreak)
                settings.isWorkOn.toggle()
            }
        } else {
            time.pomodoroIntervalCounter += 1
            start(hours: 0, minutes: time.pomodoroWork)
            settings.isWorkOn.toggle()
        }
        
        LiveActivitiesManager.startLiveActivity(activity: activity, expectedEndDate: settings.expectedEndDate)
    }
}

#Preview {
    TimerView()
}

