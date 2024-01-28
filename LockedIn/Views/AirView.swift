//
//  AirView.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 10/4/23.
//

import SwiftUI
import CoreHaptics

struct AirView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @State private var engine: CHHapticEngine?
    
    @State private var isBreathingIn = true
    @State private var height = 0.0
    @State private var breathesRemaining = 0
    @State private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var counter = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    @ObservedObject var settings = Settings()
    @ObservedObject var breath = Breath()
    
    let fadeTime = 0.5
    
    var body: some View {
        ZStack {
            Image("Sea")

            ZStack {
                Capsule()
                    .offset(y: 500)
                    .fill(Color.theme.primary.opacity(0.75))
                    .frame(width: 700, height: height)
                    .animation(.easeInOut(duration: 5.0), value: height)
                Capsule()
                    .offset(y: 500)
                    .fill(Color.theme.primary.opacity(0.75))
                    .frame(width: 700, height: height)
                    .animation(.easeInOut(duration: 5.0).delay(0.25), value: height)
                Capsule()
                    .offset(y: 500)
                    .fill(Color.theme.primary.opacity(0.75))
                    .frame(width: 700, height: height)
                    .animation(.easeInOut(duration: 5.0).delay(0.5), value: height)
                
                VStack(spacing: 0) {
                    Text(isBreathingIn ? "in" : "out")
                        .foregroundStyle(Color.theme.foreground)
                        .font(.system(size: 75))
                        .bold()
                    
                    HStack(spacing : 10) {
                        Button {
                            settings.isMusicOn.toggle()
                            if settings.isMusicOn {
                                DispatchQueue.global(qos: .userInteractive).async {
                                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                    SoundManager.instance.musicPlayer.setVolume(0.0, fadeDuration: 0.0)
                                    SoundManager.instance.playMusic(music: settings.backgroundMusic)
                                    SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: fadeTime)
                                }
                            } else {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                                fadeMusic()
                            }
                        } label: {
                            Image(systemName: settings.isMusicOn ? "speaker.wave.2.fill": "speaker.slash.fill")
                                .frame(width: 25, height: 25)
                                .id(settings.isMusicOn)
                                .transition(.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        }
                        .foregroundStyle(settings.isMusicOn ? Color.theme.foreground : Color.theme.trinary)
                        .font(.headline)
                        
                        Text("\(breathesRemaining) left")
                            .foregroundStyle(Color.theme.foreground)
                            .font(.headline)
                            .bold()
            
                        Button {
                            settings.isBreathOn.toggle()
                            
                            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        } label: {
                            Image(systemName: settings.isBreathOn ? "lungs.fill" : "lungs")
                                .frame(width: 25, height: 25)
                                .id(settings.isBreathOn)
                                .transition(.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                        
                        }
                        .foregroundStyle(settings.isBreathOn ? Color.theme.foreground : Color.theme.trinary)
                        .font(.headline)
                        .animation(.smooth, value: settings.isBreathOn)
                        
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
     
                }
                .offset(y: -250)
            }
            
            .onReceive(counter) { time in
                if breathesRemaining > 1 {
                    breathesRemaining -= 1
                    print(breathesRemaining)
                } else {
                    SoundManager.instance.soundPlayer.stop()
                    SoundManager.instance.musicPlayer.stop()
                    
                    timer.upstream.connect().cancel()
                    counter.upstream.connect().cancel()
                    
                    vibrate()
                    fadeMusic()
                    
                    UIApplication.shared.isIdleTimerDisabled = false
                    dismiss()
                    
                }
            }
            .onReceive(timer) { time in
                DispatchQueue.global(qos: .userInteractive).async {
                    isBreathingIn.toggle()
                    isBreathingIn ? (height = 1200) : (height = 0)
                    if settings.isBreathOn {
                        DispatchQueue.global(qos: .userInteractive).async {
                                SoundManager.instance.playSound(sound: isBreathingIn ? "BreatheIn" : "BreatheOut")
                        }
                        complexSuccess()
                    }
                }
                
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                vibrate()
                prepareHaptics()
                breathesRemaining = breath.breaths
                height = 1200
                complexSuccess()
                
                if settings.isMusicOn {
                    DispatchQueue.global(qos: .userInteractive).async {
                        SoundManager.instance.playMusic(music: settings.backgroundMusic)
                    }
                }
                
                if settings.isBreathOn {
                    DispatchQueue.global(qos: .userInteractive).async {
                        SoundManager.instance.playSound(sound: "BreatheIn")
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
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
                }
            }
            ToolbarItem(placement: .principal) {
                VStack {
                    Text("Breathe")
                        .mediumTitleTextStyle()
                }
            }
        }
    }
    
    func fadeMusic() {
        SoundManager.instance.musicPlayer.setVolume(0, fadeDuration: fadeTime)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(fadeTime) * 1000)) {
            SoundManager.instance.musicPlayer.pause()
        }
    }
    
    func vibrate() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func complexSuccess() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        if isBreathingIn {
            for i in stride(from: 0, to: 3, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0 + i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0 + i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1 + i)
                events.append(event)
            }
        } else {
            for i in stride(from: 0, to: 3, by: 0.1) {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(3 - i))
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(3 - i))
                let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 1 + i)
                events.append(event)
            }
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}

#Preview {
    AirView()
}
