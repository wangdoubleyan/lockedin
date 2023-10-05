//
//  AirView.swift
//  Pausepone
//
//  Created by Matsvei Liapich on 10/4/23.
//

import SwiftUI

struct AirView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
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
            
            VStack {
                Text("\(Int(breathesRemaining)) left")
                    .foregroundStyle(Color.theme.foreground)
                    .font(.headline)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
                
                Text(isBreathingIn ? "Breathe In" : "Breathe Out")
                    .foregroundStyle(Color.theme.foreground)
                    .font(.largeTitle)
                    .fontDesign(.rounded)
                    .bold()
            }
            .zIndex(5)
            .offset(y: -250)

            
            Capsule()
                .offset(y: 500)
                .fill(Color.theme.primary.opacity(0.25))
                .frame(width: 700, height: height)
                .animation(.easeInOut(duration: 5.0), value: height)
            Capsule()
                .offset(y: 500)
                .fill(Color.theme.primary.opacity(0.5))
                .frame(width: 700, height: height)
                .animation(.easeInOut(duration: 5.0).delay(0.25), value: height)
            Capsule()
                .offset(y: 500)
                .fill(Color.theme.primary.opacity(0.75))
                .frame(width: 700, height: height)
                .animation(.easeInOut(duration: 5.0).delay(0.5), value: height)
        }
        .onReceive(timer) { time in
            isBreathingIn.toggle()
            isBreathingIn ? (height = 1300) : (height = 0)
        }
        .onReceive(counter) { time in
            if breathesRemaining > 0 {
                breathesRemaining -= 1
            }
        }
        .onAppear {
            breathesRemaining = breath.breaths
            height = 1300
            UIApplication.shared.isIdleTimerDisabled = true
            vibrate()
            SoundManager.instance.playMusic(music: settings.backgroundMusic)
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
                        .bold()
                        .fontDesign(.rounded)
                        .font(.title2)
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
}

#Preview {
    AirView()
}
