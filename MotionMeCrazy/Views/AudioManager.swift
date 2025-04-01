//
//  AudioManager.swift
//  MotionMeCrazy
//
//  Created on 3/31/25.
//

import Foundation
import AVFoundation

class AudioManager {
    // Singleton instance for easy access throughout the app
    static let shared = AudioManager()
    
    // Dictionary to store audio players to prevent deallocation during playback
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    // Separate player for background music that loops continuously
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    // Flag to track if background music is currently playing
    private var isBackgroundMusicPlaying = false
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        // Setup audio session for playing sounds
        do {
            // Set category to ambient so sound plays even when device is on silent
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session successfully configured")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
    
    // Play a sound file once
    func playSound(named soundName: String, fileExtension: String = "mp3") {
        print("Attempting to play sound: \(soundName)")
        
        // Get URL for the sound file from the app bundle
        guard let url = Bundle.main.url(forResource: soundName, withExtension: fileExtension) else {
            print("❌ Sound file not found: \(soundName).\(fileExtension)")
            return
        }
        
        do {
            // Create and configure the audio player
            let player = try AVAudioPlayer(contentsOf: url)
            
            // Log that we're about to play
            print("✅ Created player for sound: \(soundName)")
            
            // Prepare and play
            player.prepareToPlay()
            let success = player.play()
            print("✅ Started playing sound: \(soundName), success: \(success)")
            
            // Store reference to prevent deallocation during playback
            audioPlayers[soundName] = player
            
            // Use a timer to clean up the player after it finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.5) { [weak self] in
                print("🗑 Cleaning up player for sound: \(soundName)")
                self?.audioPlayers.removeValue(forKey: soundName)
            }
        } catch {
            print("❌ Failed to play sound: \(error) for \(url)")
        }
    }
    
    // Play background music with looping
    func playBackgroundMusic(named musicName: String, fileExtension: String = "mp3") {
        print("Attempting to play background music: \(musicName)")
        
        // If background music is already playing, stop it first
        if isBackgroundMusicPlaying {
            stopBackgroundMusic()
        }
        
        guard let url = Bundle.main.url(forResource: musicName, withExtension: fileExtension) else {
            print("❌ Music file not found: \(musicName).\(fileExtension)")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.5 // Lower volume for background music
            backgroundMusicPlayer?.prepareToPlay()
            let success = backgroundMusicPlayer?.play() ?? false
            isBackgroundMusicPlaying = success
            print("✅ Started playing background music: \(musicName), success: \(success)")
        } catch {
            print("❌ Failed to play background music: \(error)")
        }
    }
    
    // Stop background music
    func stopBackgroundMusic() {
        print("🛑 Stopping background music")
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        isBackgroundMusicPlaying = false
    }
    
    // Pause background music
    func pauseBackgroundMusic() {
        print("⏸ Pausing background music")
        backgroundMusicPlayer?.pause()
    }
    
    // Resume background music
    func resumeBackgroundMusic() {
        print("▶️ Resuming background music")
        if let player = backgroundMusicPlayer {
            let success = player.play()
            print("Resume success: \(success)")
        } else {
            print("❌ No background music player to resume")
        }
    }
    
    // Get current background music status
    func isPlayingBackgroundMusic() -> Bool {
        return isBackgroundMusicPlaying && (backgroundMusicPlayer?.isPlaying ?? false)
    }
}
