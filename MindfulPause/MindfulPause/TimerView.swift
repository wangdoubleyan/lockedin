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
    
    @IBAction func playSound(sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player.play()
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
        Double(time.hr * 60 * 60 + time.min * 60)
    }
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            ZStack {
                Circle()
                    .stroke(lineWidth: stroke)
                    .foregroundStyle(Color.theme.secondary)
                    .opacity(0.2)
                    .animation(.smooth(duration: 1), value: stroke)
                
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
                    } else {
                        self.timer.upstream.connect().cancel()
                        isTimerPaused.toggle()
                    }
                    
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    if isTimerPaused {
                        Image(systemName: "play.fill")
                            .font(.system(size: 40))
                        
                    } else {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 40))
                    }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.83)
            }

        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    HStack(spacing: 5) {
                        Text(Image(systemName: "arrow.left"))
                            .fontWeight(.bold)
                        Text("Back")
                            .font(.headline)

                    }
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

    
    func snapBack() {
        if Double(timeRemaining) > 0 {
            DispatchQueue.main.async {
                if settings.isSnapBackOn {
                    SoundManager.instance.playSound(sound: "SnapBackSound")
                    
                    haptic()
                    
                    flash = 1
                    
                    withAnimation(.easeOut.delay(0.4)) {
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
        if time.hr == 0 && time.min == 0 {
            time.min = 1
        }
        calculateTimeRemaining(hours: time.hr, minutes: time.min)
        stroke = 40.0
        opacity = 1
        UIApplication.shared.isIdleTimerDisabled = true
        start()
    }
    
    func start() {
        vibrate()
    }
    
    func end() {
        if counter == 0 {
            counter += 1
            vibrate()
            SoundManager.instance.playSound(sound: "EndSound")
            healthKitManager.saveMindfulMinutes(minutes: totalTime)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            UIApplication.shared.isIdleTimerDisabled = false
            dismiss()
        }
        
    }
}
    
#Preview {
    TimerView(time: Time(), settings: Settings())
}
