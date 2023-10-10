//
//  TimerView.swift
//  Pausepone
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import AVKit

class SoundManager {
    @ObservedObject var settings = Settings()
    static let instance = SoundManager()
    
    var soundPlayer = AVAudioPlayer()
    var musicPlayer = AVAudioPlayer()
    
    @IBAction func playSound(sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            print(url)
            soundPlayer.stop()
            soundPlayer = try AVAudioPlayer(contentsOf: url)
            soundPlayer.volume = 1
            musicPlayer.prepareToPlay()
            soundPlayer.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func playMusic(music: String) {
        if settings.isMusicOn {
            guard let url = Bundle.main.url(forResource: music, withExtension: "mp3") else { return }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
        
                musicPlayer.stop()
                musicPlayer = try AVAudioPlayer(contentsOf: url)
                musicPlayer.numberOfLoops =  -1
                musicPlayer.setVolume(0.0, fadeDuration: 0.0)
                musicPlayer.prepareToPlay()
                musicPlayer.play()
                musicPlayer.setVolume(1, fadeDuration: 1)
            } catch let error {
                print("Error playing sound. \(error.localizedDescription)")
            }
            
        }
    }
}

struct TimerView: View {
    @ObservedObject private var healthKitManager = HealthKitManager()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var time = Time()
    @ObservedObject var settings = Settings()
    
    @State private var progress = 0.0
    @State private var timeRemaining = 0
    @State private var stroke = 0.0
    @State private var opacity = 0.0
    @State private var flash = 0.0
    @State private var counter = 0
    @State private var isTimerPaused = false
    @State private var intervalCounter = -1.0

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let fadeTime = 0.5
    
    var totalTime: Int {
        time.hr * 60 * 60 + time.min * 60
    }
    
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
                    if timeRemaining > 0 {
                        Text("\(printFormattedTime(timeRemaining))")
                            .largeTitleTextStyle()
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Done!")
                            .largeTitleTextStyle()
                    }
                }
                
            }
            .frame(width: 250, height: 250)
            .onAppear {
                if time.hr == 0 && time.min == 0 {
                    time.min = 1
                }
                appear()
            }
            .onReceive(timer) { time in
                if timeRemaining <= 0 {
                    end()
                    return
                }
                
                timeRemaining -= 1
                progress += 1.0 / Double(totalTime)
                
                if intervalCounter == 0 {
                    snap()
                    intervalCounter = settings.interval - 1
                } else if intervalCounter < 0 {
                    intervalCounter = settings.interval - 2
                } else {
                    intervalCounter -= 1
                }
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
                                SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: fadeTime)
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
                        .fontDesign(.rounded)
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
                        .fontDesign(.rounded)
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(fadeTime * 1000))) {
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
    
    func calculateTimeRemaining(hours: Int, minutes: Int) {
        timeRemaining = hours * 60 * 60 + minutes * 60
    }
        
    func formatTime(_ seconds: Int) -> (Int, Int, Int) {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = (seconds % 3600) % 60
        return (hours, minutes, remainingSeconds)
    }

    func printFormattedTime(_ seconds: Int) -> String {
        let (h, m, s) = formatTime(seconds)
        
        var timeComponents: [String] = []
        
        if h > 0 { timeComponents.append("\(h) hr") }
        if m > 0 { timeComponents.append("\(m) min") }
        if s > 0 { timeComponents.append("\(s) sec") }
        
        return timeComponents.joined(separator: "\n")
    }

    
    func snap() {
        if Double(timeRemaining) > 0 {
            if settings.isSnapOn {
                SoundManager.instance.playSound(sound: "SnapSound")
                
                haptic()
                
                flash = 1
                
                withAnimation(.easeOut.delay(0.5)) {
                    flash = 0.0
                }
            }
        }
    }
    
    func vibrate() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    func haptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    func appear() {
        UIApplication.shared.isIdleTimerDisabled = true
        calculateTimeRemaining(hours: time.hr, minutes: time.min)
        vibrate()
        stroke = 40.0
        opacity = 1
        SoundManager.instance.playSound(sound: "Sound")
        SoundManager.instance.playMusic(music: settings.backgroundMusic)
    }
    
    func end() {
        if counter == 0 {
            counter += 1
            vibrate()
            SoundManager.instance.playSound(sound: "Sound")
            fadeMusic()
            healthKitManager.saveMindfulMinutes(minutes: Double(totalTime))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            UIApplication.shared.isIdleTimerDisabled = false
                        
            SoundManager.instance.soundPlayer.stop()
            SoundManager.instance.musicPlayer.stop()
            
            dismiss()
        }
    }
    
    func fadeMusic() {
        SoundManager.instance.musicPlayer.setVolume(0, fadeDuration: fadeTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(fadeTime) * 1000)) {
            SoundManager.instance.musicPlayer.pause()
        }
    }
    
    func pauseTimer() {
        self.timer.upstream.connect().cancel()
        isTimerPaused.toggle()
        fadeMusic()
    }
    
    func resumeTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        isTimerPaused.toggle()
            
        if settings.isMusicOn {
            SoundManager.instance.musicPlayer.setVolume(0.0, fadeDuration: 0.0)
            SoundManager.instance.playMusic(music: settings.backgroundMusic)
            SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: fadeTime)
        }
    }
}

#Preview {
    TimerView()
}

