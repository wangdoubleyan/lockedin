//
//  TimerView.swift
//  MindfulPause
//
//  Created by Matsvei Liapich on 8/25/23.
//

import SwiftUI
import AVKit

class SoundManager {
    static let instance = SoundManager()
    
    var player = AVAudioPlayer()
    var player1 = AVAudioPlayer()
    
    @IBAction func playSound(sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            print(url)
            player.volume = 2
            player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
        
    }
    
    @IBAction func playMusic(music: String) {
        guard let url = Bundle.main.url(forResource: music, withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player1 = try AVAudioPlayer(contentsOf: url)
            player1.numberOfLoops =  -1
            player1.setVolume(0.0, fadeDuration: 0.0)
            player1.play()
            player1.setVolume(0.75, fadeDuration: 3.0)
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
        }
        
    }
}

struct TimerView: View {
    @ObservedObject private var healthKitManager = HealthKitManager()
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var time: Time
    @ObservedObject var settings: Settings
    
    @State private var progress = 0.0
    @State private var timeRemaining = 0
    @State private var stroke = 0.0
    @State private var opacity = 0.0
    @State private var flash = 0.0
    @State private var counter = 0
    @State private var isTimerPaused = false
    @State private var pausedAt = 0
    @State private var intervalCounter = -1.0

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var totalTime: Double {
        Double(time.hr * 60 * 60 + time.min * 60 + time.sec)
    }
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            ZStack {
                Circle()
                    .stroke(lineWidth: stroke)
                    .foregroundStyle(Color.theme.secondary)
                    .opacity(0.1)
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
                            .foregroundStyle(Color.theme.foreground)
                            .font(.largeTitle)
                            .bold()
                            .fontDesign(.rounded)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Done!")
                            .foregroundStyle(Color.theme.foreground)
                            .font(.largeTitle)
                            .bold()
                            .fontDesign(.rounded)
                    }
                }
            
            }
            .frame(width: 250, height: 250)
            .onAppear {
                if time.hr >= 1 || time.min >= 1 {
                    time.sec = 0
                } else if time.hr == 0 && time.min == 0 && time.sec == 0 {
                    time.min = 1
                }
                print("\(time.hr) hours")
                print("\(time.min) minutes")
                print("\(time.sec) seconds")
                appear()
                
            }
            .onReceive(timer) { time in
                if timeRemaining <= 0 {
                    end()
                    return
                }
                
                timeRemaining -= 1
                progress += 1.0 / totalTime
                
                if intervalCounter == 0 {
                    snapBack()
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
            
            GeometryReader { geometry in
                Button {
                    if isTimerPaused {
                        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                        isTimerPaused.toggle()
                        SoundManager.instance.player1.setVolume(0.0, fadeDuration: 0.0)
                        SoundManager.instance.player1.play()
                        SoundManager.instance.player1.setVolume(0.75, fadeDuration: 1.0)
                    } else {
                        self.timer.upstream.connect().cancel()
                        isTimerPaused.toggle()
                        SoundManager.instance.player1.setVolume(0, fadeDuration: 1.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            SoundManager.instance.player1.pause()
                        }
                    }
                    
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    if isTimerPaused {
                        Image(systemName: "play.fill")
                            .font(.system(size: 45))
                            .symbolRenderingMode(.hierarchical)
                    } else {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 45))
                            .symbolRenderingMode(.hierarchical)
                    }
                        
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.83)
            }

        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    fadeOut()
                } label: {
                    Text(Image(systemName: "arrow.uturn.backward.circle.fill"))
                        .font(.system(size: 35))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color.theme.secondary.opacity(0.8))
                }
            }
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Pause")
                        .bold()
                        .fontDesign(.rounded)
                        .font(.title2)
                }
            }
        }
    }
    
    
    func calculateTimeRemaining(hours: Int, minutes: Int, seconds: Int) {
        timeRemaining = hours * 60 * 60 + minutes * 60 + seconds
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

    
    func snapBack() {
        if Double(timeRemaining) > 0 {
            if settings.isSnapBackOn {
                DispatchQueue.global(qos: .background).async {
                    SoundManager.instance.playSound(sound: "SnapBackSound")
                }
                
                haptic()
                
                DispatchQueue.main.async {
                    flash = 1
                    
                    withAnimation(.easeOut.delay(0.5)) {
                        flash = 0.0
                    }
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
        calculateTimeRemaining(hours: time.hr, minutes: time.min, seconds: time.sec)
        stroke = 40.0
        opacity = 1
        UIApplication.shared.isIdleTimerDisabled = true
        vibrate()
        DispatchQueue.global(qos: .background).async {
            SoundManager.instance.playSound(sound: "Sound")
            SoundManager.instance.playMusic(music: settings.backgroundMusic)
        }
    }
    
    func end() {
        if counter == 0 {
            counter += 1
            vibrate()
            fadeOut()
            DispatchQueue.global(qos: .background).async {
                SoundManager.instance.playSound(sound: "Sound")
            }
            healthKitManager.saveMindfulMinutes(minutes: totalTime)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            UIApplication.shared.isIdleTimerDisabled = false
            dismiss()
            time.sec = 0
        }
        
    }
    
    func fadeOut() {
        DispatchQueue.global(qos: .background).async {
            SoundManager.instance.player1.setVolume(0, fadeDuration: 3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            SoundManager.instance.player1.pause()
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(time: Time(), settings: Settings())
    }
}
