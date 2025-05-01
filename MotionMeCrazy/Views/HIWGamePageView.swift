import SwiftUI
import AVFoundation
//
//  HIWGamePageView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 2/23/25.
//

struct HIWGamePageView:View {
    @EnvironmentObject var appState: AppState

    // game buttons
    @Environment(\.presentationMode) var presentationMode
    @State private var showSettings = false  // shows settings pop up
    @State private var showPauseMenu = false  // shows pause menu pop up
    @State private var showQuitConfirmation = false // shows quit
    @State private var isPlaying = true  // checks if game is active
    @State private var openedFromPauseMenu = false // to show where the game settings was closed from (pause or lobby) - tea
    @State private var isMuted = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var soundEffectPlayer: AVAudioPlayer?
    @State private var isSoundEffectMuted = true
    
    // game stats
    @State private var score: Int = 1000
    @State private var health: Double = 30  // Adjust based on game logic
    @State private var maxHealth: Double = 100
    @State private var progress: String = "Level 1/10"
    
    
    private func startObstacleCycle(resumeFromPause: Bool = false) {
        print("filler")
    }
    // tutorial
    @Binding var sectionFrames: [Int: CGRect]?
    @EnvironmentObject var webSocketManager: WebSocketManager
     
     init(sectionFrames: Binding<[Int: CGRect]?> = .constant(nil)) {
         _sectionFrames = sectionFrames
     }
     
    
    
    
    var body: some View {
        ZStack{
            Image(appState.darkMode ? "background_dm" : "background")
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                VStack() {
                    HStack() {
                        Spacer()
                        
                        // pause button during gameplay
                        Button(action: {
                            showPauseMenu = true
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40, alignment: .topLeading)
                                .foregroundColor(.darkBlue)
                                .padding()
                        }
                        .accessibilityIdentifier("pauseButton")
                    }
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: SectionFrameKey.self, value: [3: proxy.frame(in: .global)])
                    })
                }
                VStack() {
                    // Score Section
                    HStack {
                        CustomText(config: CustomTextConfig(text: appState.localized("Score"), titleColor: .darkBlue, fontSize: 20))
                            .font(.headline)
                            .bold()
                        Spacer()
                        CustomText(config: CustomTextConfig(text:"\(score)", titleColor: .darkBlue, fontSize: 18))
                            .font(.body)
                    }
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: SectionFrameKey.self, value: [0: proxy.frame(in: .global)])
                    })
                    
                    // Health Section
                    HStack {
                        CustomText(config: CustomTextConfig(text: appState.localized("Health"), titleColor: .darkBlue, fontSize: 20))
                            .font(.headline)
                            .bold()
                        Spacer()
                        CustomText(config: CustomTextConfig(text:"0", titleColor: .darkBlue, fontSize: 18))
                            .font(.body)
                        ProgressView(value: health, total: maxHealth)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 50)  // Adjust width as needed
                            .tint(.darkBlue)
                        CustomText(config: CustomTextConfig(text:"100", titleColor: .darkBlue, fontSize: 18))
                            .font(.body)
                    }
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: SectionFrameKey.self, value: [1: proxy.frame(in: .global)])
                    })
                    
                    // Progress Section
                    HStack {
                        CustomText(config: CustomTextConfig(text: appState.localized("Progress"), titleColor: .darkBlue, fontSize: 20))
                            .font(.headline)
                            .bold()
                        Spacer()
                        CustomText(config: CustomTextConfig(text:"\(progress)", titleColor: .darkBlue, fontSize: 18))
                            .font(.body)
                    }
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: SectionFrameKey.self, value: [2: proxy.frame(in: .global)])
                    })
                }
                .padding()
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .onPreferenceChange(SectionFrameKey.self) { newValues in
                    if var frames = sectionFrames {
                        frames.merge(newValues) { _, new in new }
                        sectionFrames = frames
                    }
                }
                Spacer()
            }
            
            // pause menu for game
            if showPauseMenu {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPauseMenu = false
                    }
                
                PauseMenuView(
                    isPlaying: $isPlaying,
                    showPauseMenu: $showPauseMenu,
                    showSettings: $showSettings,
                    showQuitConfirmation: $showQuitConfirmation,
                    openedFromPauseMenu: $openedFromPauseMenu, // tea change
                    isMuted: $isMuted,
                    audioPlayer: $audioPlayer,
                    soundEffectPlayer: $soundEffectPlayer,
                    isSoundEffectMuted: $isSoundEffectMuted,
                    startObstacleCycle: startObstacleCycle
                )
                .frame(width: 300, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .accessibilityIdentifier("pauseMenuView")
            }
        }
    }
}

// Preference Key to track section positions
struct SectionFrameKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]
    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

//#Preview {
//    HIWGamePageView()
//}
