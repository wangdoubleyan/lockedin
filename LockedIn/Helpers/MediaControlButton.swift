//
//  MediaControlButton.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 4/24/24.
//

import SwiftUI

struct MediaControlButton: View {
    @ObservedObject var settings = Settings()
    
    var body: some View {
        HStack {
            HStack {
                Button {
                    settings.isMusicOn.toggle()
                    if settings.isMusicOn {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        SoundManager.instance.musicPlayer.setVolume(0.0, fadeDuration: 0.0)
                        SoundManager.instance.playMusic(music: settings.backgroundMusic)
                        SoundManager.instance.musicPlayer.setVolume(1, fadeDuration: settings.musicFadeTime)
                    } else {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        SoundManager.instance.fadeMusic()
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
                    settings.isTimerPaused ? TimerView().resumeTimer() : TimerView().pauseTimer()
                    
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    if settings.isTimerPaused {
                        Image(systemName: "play.fill")
                            .id(settings.isTimerPaused)
                            .transition(.asymmetric(insertion: .scale, removal: .scale).combined(with: .opacity))
                            .font(.system(size: 35))
                        
                    } else {
                        Image(systemName: "pause.fill")
                            .id(settings.isTimerPaused)
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
    
    
}

#Preview {
    MediaControlButton()
}
