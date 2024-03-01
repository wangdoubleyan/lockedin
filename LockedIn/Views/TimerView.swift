//
//  TimerView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import StoreKit

struct TimerView: View {
    @ObservedObject private var healthKitManager = HealthKitManager()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.requestReview) var requestReview
    
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
    
    @State private var startDate = Date()
    
//    Calculated when user starts timer
    @State private var expectedEndDate = Date()
    
//    Calculated when user exits timer
    @State private var actualEndDate = Date()
    
    @State private var isWorkOn = true
    @State private var pauseTime = Date()

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var snapTimer = Timer.publish(every: Settings().snapInterval, on: .main, in: .common).autoconnect()
    
    let musicFadeTime = 0.5
    
    var body: some View {
        ZStack {
//            Image("Mountain")
//                .resizable()
            
            GradientView()

            ZStack {
                Circle()
                    .stroke(lineWidth: stroke)
                    .foregroundStyle(.ultraThinMaterial)
                    .animation(.linear(duration: 1), value: stroke)
                
                Circle()
                    .trim(from: 0.0, to: min(progress, 1.0))
                    .stroke(Color.theme.primary.opacity(opacity), style: StrokeStyle(lineWidth: 30.0, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270))
                    .animation(.easeIn(duration: 3), value: opacity)
                    .animation(.linear(duration: 1), value: progress)
                
                
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
                        .clipShape(RoundedRectangle(cornerRadius: 100))
                    }
                }
                .padding(.bottom, 130)
                VStack {
                    Text("\(time.pomodoroNumberOfIntervals - pomodoroIntervalCounter + 1) left")
                    .foregroundStyle(Color.theme.foreground)
                    .font(.headline)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                }
                .padding(.top, 130)
                
                HStack {
                    Text("\(timerCounter)")
                        .largeTitleTextStyle()
                        .contentTransition(.numericText())
                        .fontDesign(.monospaced)
                }
            }
            .padding(40)
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
            
            Color.theme.secondary
                .ignoresSafeArea()
                .opacity(flash)
                .animation(.easeInOut(duration: 1), value: flash)
            
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
            .padding(.vertical, 50)
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    UIApplication.shared.isIdleTimerDisabled = false
                    
                    fadeMusic()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(musicFadeTime * 1000))) {
                        SoundManager.instance.soundPlayer.stop()
                        SoundManager.instance.musicPlayer.stop()
                    }
                    
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text(Image(systemName: "arrow.uturn.backward.circle.fill"))
                        .font(.system(size: 35))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.theme.primary)
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
        expectedEndDate = Date()
        expectedEndDate = Calendar.current.date(byAdding: .minute, value: initialTime, to: expectedEndDate)!
        UIApplication.shared.isIdleTimerDisabled = true
        vibrate()
        stroke = 40.0
        opacity = 1
        DispatchQueue.global(qos: .userInteractive).async {
            SoundManager.instance.playSound(sound: "Sound")
            if isWorkOn {
                SoundManager.instance.playMusic(music: settings.backgroundMusic)
            } else {
                SoundManager.instance.musicPlayer.stop()
            }
        }
    }
    
    
    func updateCountdown() {
        let now = Date()
        let diff = expectedEndDate.timeIntervalSince(now)
        
        if diff <= 0 {
            if settings.selectedItem == "Simple" {
                end()
            } else {
                switchPomodoroModes()
                print("I ran too yehoo!")
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
        }
        
        review.cycleCount += 1
        if review.cycleCount % 50 == 0 {
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
    }
    
    func resumeTimer() {
        let elapsedTime = Date().timeIntervalSince(pauseTime)
        
//        1.5 added seconds are necessary to account for a lost second if paused at the end of a second
        expectedEndDate = expectedEndDate + elapsedTime + 1.5
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        snapTimer = Timer.publish(every: settings.snapInterval, on: .main, in: .common).autoconnect()
        isTimerPaused.toggle()
            
        if settings.isMusicOn {
            SoundManager.instance.musicPlayer.setVolume(0.0, fadeDuration: 0.0)
            SoundManager.instance.playMusic(music: settings.backgroundMusic)
            SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: musicFadeTime)
        }
    }
    
    func switchPomodoroModes() {
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
    }
}

#Preview {
    TimerView()
}

