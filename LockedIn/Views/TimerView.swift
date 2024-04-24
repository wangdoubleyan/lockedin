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
    @State private var isTimerPaused = false
    @State private var timerCounter = "Start"
    @State private var initialTime = 0
    @State private var pomodoroIntervalCounter = 1
    @State private var showingEndAlert = false
    
    @State private var startDate = Date()
        
//    Calculated when user exits timer
    @State private var actualEndDate = Date()
    
    @State private var isWorkOn = true
    @State private var pauseTime = Date()

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var snapTimer = Timer.publish(every: Settings().snapInterval, on: .main, in: .common).autoconnect()
    
    @State var activity: Activity<TimeTrackingAttributes>? = nil
    
    
    
    
    let musicFadeTime = 0.5
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                VStack {
                    ZStack {
                        ProgressCircle(stroke: stroke, progress: progress, opacity: opacity, timerText: timerCounter)
                        
                        VStack {
                            if settings.selectedItem == "Pomodoro" {
                                Button {
                                    switchPomodoroModes()
                                } label: {
                                    Image(systemName: "forward.fill")
                                    Text(isWorkOn ? "Work" : "Break")
                                }
                                .foregroundStyle(Color.theme.background)
                                .font(.headline)
                                .bold()
                                .padding(10)
                                .background(Color.theme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                            }
                        }
                        .offset(y: -60)
                        
                        VStack {
                            Text("\(time.pomodoroNumberOfIntervals - pomodoroIntervalCounter + 1) left")
                                .foregroundStyle(Color.theme.foreground)
                                .font(.headline)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                            
                        }
                        .offset(y: 60)
                        
                        .onAppear {
                            startDate = Date()
                            
                            //            Makes sure that a timer of 0 is not possible
                            if time.hr == 0 && time.min == 0 {
                                time.min = 1
                            }
                            
                            settings.selectedItem == "Simple" ? start(hours: time.hr, minutes: time.min) : start(hours: 0, minutes: time.pomodoroWork)
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
                
                HStack {
                    HStack {
                        Button {
                            settings.isMusicOn.toggle()
                            if settings.isMusicOn {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                SoundManager.instance.musicPlayer.setVolume(0.0, fadeDuration: 0.0)
                                SoundManager.instance.playMusic(music: settings.backgroundMusic)
                                SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: musicFadeTime)
                            } else {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                fadeMusic()
                            }
                        } label: {
                            Image(systemName: settings.isMusicOn ? "speaker.wave.2.fill": "speaker.slash.fill")
                                .frame(width: 25, height: 25)
                                .id(settings.isMusicOn)
                                .transition(.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                            HStack {
                                Text("Music")
                            }
                        }
                        .foregroundStyle(settings.isMusicOn ? Color.theme.foreground : Color.theme.trinary)
                        .font(.headline)
                        .bold()
                    }
                    .frame(width: 100, alignment: .leading)
                    
                    HStack {
                        Button {
                            isTimerPaused ? resumeTimer() : pauseTimer()
                            
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        } label: {
                            if isTimerPaused {
                                Image(systemName: "play.fill")
                                    .id(isTimerPaused)
                                    .transition(.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                                    .font(.system(size: 35))
                                
                            } else {
                                Image(systemName: "pause.fill")
                                    .id(isTimerPaused)
                                    .transition(.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                                    .font(.system(size: 35))
                            }
                        }
                    }
                    .foregroundStyle(Color.theme.foreground)
                    .frame(width: 65, height: 65, alignment: .center)
                    
                    HStack {
                        Button {
                            settings.isSnapOn.toggle()
                            
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        } label: {
                            Image(systemName: settings.isSnapOn ? "bell.badge.waveform.fill" : "bell.slash.fill")
                                .frame(width: 25, height: 25)
                                .id(settings.isSnapOn)
                                .transition(.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                            HStack {
                                Text("Snaps")
                            }
                        }
                        .foregroundStyle(settings.isSnapOn ? Color.theme.foreground : Color.theme.trinary)
                        .font(.headline)
                        .bold()
                    }
                    .frame(width: 100, alignment: .trailing)
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
            }
            .padding()
            .padding(.bottom, 25)
            
            
            
//            Color.theme.secondary
//                .ignoresSafeArea()
//                .opacity(flash)
//                .animation(.easeInOut(duration: 1), value: flash)
                
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
            if isWorkOn {
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
        
        fadeMusic()
        actualEndDate = Date()
        timerCounter = "Finish"
        SoundManager.instance.playSound(sound: "Sound")
        timer.upstream.connect().cancel()
        snapTimer.upstream.connect().cancel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            UIApplication.shared.isIdleTimerDisabled = false
                        
            SoundManager.instance.soundPlayer.stop()
            SoundManager.instance.musicPlayer.stop()
            
            healthKitManager.saveMindfulMinutes(start: startDate, end: actualEndDate)
            
            dismiss()
            presentationMode.wrappedValue.dismiss()
        }
        
        review.cycleCount += 1
        if review.cycleCount % 30 == 0 {
            requestReview()
        }
    }
    
    func fadeMusic() {
        SoundManager.instance.musicPlayer.setVolume(0, fadeDuration: musicFadeTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(musicFadeTime) * 1000)) {
            SoundManager.instance.musicPlayer.pause()
        }
    }
    
    func pauseTimer() {
        pauseTime = Date()
        timer.upstream.connect().cancel()
        snapTimer.upstream.connect().cancel()
        isTimerPaused.toggle()
        fadeMusic()
        LiveActivitiesManager.stopLiveActivity()
    }
    
    func resumeTimer() {
        let elapsedTime = Date().timeIntervalSince(pauseTime)
        
//        1.5 added seconds are necessary to account for a lost second if paused at the end of a second
        settings.expectedEndDate = settings.expectedEndDate + elapsedTime + 1.5
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        snapTimer = Timer.publish(every: settings.snapInterval, on: .main, in: .common).autoconnect()
        isTimerPaused.toggle()
            
        if settings.isMusicOn {
            SoundManager.instance.musicPlayer.setVolume(0.0, fadeDuration: 0.0)
            SoundManager.instance.playMusic(music: settings.backgroundMusic)
            SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: musicFadeTime)
        }
        LiveActivitiesManager.startLiveActivity(activity: activity, expectedEndDate: settings.expectedEndDate)
    }
    
    func switchPomodoroModes() {
        LiveActivitiesManager.stopLiveActivity()
        
        if isWorkOn {
            if pomodoroIntervalCounter == time.pomodoroNumberOfIntervals {
                progress = 100.0
                pomodoroIntervalCounter += 1
                end()
            } else {
                start(hours: 0, minutes: time.pomodoroBreak)
                isWorkOn.toggle()
            }
        } else {
            pomodoroIntervalCounter += 1
            start(hours: 0, minutes: time.pomodoroWork)
            isWorkOn.toggle()
        }
        
        LiveActivitiesManager.startLiveActivity(activity: activity, expectedEndDate: settings.expectedEndDate)
    }
}

#Preview {
    TimerView()
}

