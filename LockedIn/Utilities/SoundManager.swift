//
//  SoundManager.swift
//  LockedIn
//
//  Created by Matsvei Liapich on 12/21/23.
//

import Foundation
import SwiftUI
import AVKit

class SoundManager {
    @ObservedObject var settings = Settings()
    static let instance = SoundManager()
    
    var soundPlayer = AVAudioPlayer()
    var musicPlayer = AVAudioPlayer()
    
    func playSound(sound: String) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
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
    
    func playMusic(music: String) {
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
