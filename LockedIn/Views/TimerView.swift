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
    @State private var progress = 0.0
    @State private var timeRemaining = 0
    @State private var stroke = 0.0
    @State private var opacity = 0.0
    @State private var flash = 0.0
    @State private var counter = 0
    @State private var isTimerPaused = false
    @State private var intervalCounter = -1.0
    @State private var timerCounter = "Start"
    @State private var initialTime = 0
    @State private var totalTime = 0.0
    @State private var endDate = Date()
    @State private var isWorkOn = true
    @State private var pauseTime = Date()

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let musicFadeTime = 0.5
    
    var body: some View {
        ZStack {
            Image("Mountain")
                .resizable()

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
                    HStack(spacing: 5) {
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
                .padding(.bottom, 115)
                
                HStack {
                    Text("\(timerCounter)")
                        .largeTitleTextStyle()
                        .contentTransition(.numericText())
                        .fontDesign(.monospaced)
                }
            }
            .padding(40)
            .onAppear {
                settings.selectedItem == "Simple" ? start(hours: time.hr, minutes: time.min) : start(hours: 0, minutes: time.pomodoroWork)
            }
            
            .onReceive(timer) { time in
                updateCountdown()
                print(time)
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
            SoundManager.instance.playSound(sound: "SnapSound")
            
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
    
    func start(hours: Int, minutes: Int) {
        if time.hr == 0 && time.min == 0 {
            time.min = 1
        }
        
        self.initialTime = hours * 60 + minutes
        self.endDate = Date()
        self.endDate = Calendar.current.date(byAdding: .minute, value: initialTime, to: endDate)!
        print(endDate)
        UIApplication.shared.isIdleTimerDisabled = true
        vibrate()
        stroke = 40.0
        opacity = 1
        DispatchQueue.global(qos: .userInteractive).async {
            SoundManager.instance.playSound(sound: "Sound")
            SoundManager.instance.playMusic(music: settings.backgroundMusic)
        }
    }
    
    func updateCountdown() {
        let now = Date()
        let diff = endDate.timeIntervalSince(now)
        
        if diff <= 0 {
            if settings.selectedItem == "Simple" {
                self.timer.upstream.connect().cancel()
                end()
            } else {
                if isWorkOn {
                    progress = 0.0
                    start(hours: 0, minutes: time.pomodoroBreak)
                    isWorkOn.toggle()
                } else {
                    progress = 0.0
                    start(hours: 0, minutes: time.pomodoroWork)
                    isWorkOn.toggle()
                }
            }
        } else {
            progress += 1.0 / Double(initialTime * 60)
            
            let hours = Int(diff / 3600)
            let minutes = Int((diff / 60).truncatingRemainder(dividingBy: 60))
            let seconds = Int(diff.truncatingRemainder(dividingBy: 60))
            
            self.initialTime = initialTime
            
            withAnimation {
                if hours == 0 && minutes == 0 {
                    self.timerCounter = String(format: "%02d", seconds)
                } else if hours == 0 {
                    self.timerCounter = String(format: "%d:%02d", minutes, seconds)
                } else {
                    self.timerCounter = String(format: "%d:%d:%02d", hours, minutes, seconds)
                }
            }
        }
        
    }

    func end() {
        timerCounter = "Finish"
        SoundManager.instance.playSound(sound: "Sound")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            UIApplication.shared.isIdleTimerDisabled = false
                        
            SoundManager.instance.soundPlayer.stop()
            SoundManager.instance.musicPlayer.stop()
            
            healthKitManager.saveMindfulMinutes(minutes: Double(totalTime))
            
            dismiss()
        }
        
        review.cycleCount += 1
        if review.cycleCount % 20 == 0 {
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
        self.timer.upstream.connect().cancel()
        isTimerPaused.toggle()
        fadeMusic()
    }
    
    func resumeTimer() {
        let elapsedTime = Date().timeIntervalSince(pauseTime)
        endDate = endDate + elapsedTime + 1
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        isTimerPaused.toggle()
            
        if settings.isMusicOn {
            SoundManager.instance.musicPlayer.setVolume(0.0, fadeDuration: 0.0)
            SoundManager.instance.playMusic(music: settings.backgroundMusic)
            SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: musicFadeTime)
        }
    }
}

#Preview {
    TimerView()
}

