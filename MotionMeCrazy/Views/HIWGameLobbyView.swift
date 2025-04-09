
import SwiftUI
import AVFoundation

//
//  HIWGameLobbyView.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto.
//


struct HIWGameLobbyView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showSettings = false
    @State private var showPauseMenu = false
    @State private var showQuitConfirmation = false
    @State private var showTutorial = false
    @State private var isPlaying = false
    @State private var openedFromPauseMenu = false
    @State private var selectedDifficulty: SettingsView.Difficulty = .normal
    @State private var fetchingError: Bool = false
    @State private var obstacleIndex = 0
    @State private var timer: Timer? = nil
    @State private var showCompletionScreen = false
    @State private var currentLevel = 1
    @State private var obstacles: [String] = []
    @State private var levelImageMap: [Int: [String]] = [:]
    @State private var checkCollisionOn: String!
    
    //Mute stuff
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isMuted = false


    //Loading audio
    func loadAudio() {
        //getting royalty free song lol
        guard let url = Bundle.main.url(forResource: "best-game-console-301284", withExtension: "mp3") else {
            print("Audio file not found.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1  // loops forever
            audioPlayer?.prepareToPlay()
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
            print("Playing audio!!")
        } catch {
            print("audio file loading fail: \(error)")
        }
    }
    
    //TODO: ADD FUNCTIONALITY game stats
    @State private var score: Int = 100  //TODO: Adjust
    @State private var health: Double = 5  //TODO: Adjust
    @State private var maxHealth: Double = 5  //TODO: Adjust
    @State private var progress: String = "Level 1/10"

    private let wallsPerLevel = 4  // Number of walls per level

    var userId: Int
    var gameId: Int

    var body: some View {
        ZStack {
            ViewControllerView(obstacleImageName: $checkCollisionOn)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 50) {
                if !isPlaying {
                    CustomHeader(config: .init(title: "Hole in the Wall"))
                        .accessibilityIdentifier("holeInTheWallTitle")
                }

                VStack(spacing: 40) {
                    if !isPlaying {
                        Button(action: {
                            isPlaying = true
                            startObstacleCycle()
                        }) {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.darkBlue)
                        }
                        .accessibilityIdentifier("playButton")
                    }
                }
            }

            VStack {
                HStack {
                    Spacer()

                    if !isPlaying {
                        Button(action: {
                            showTutorial = true
                        }) {
                            Image(
                                systemName: "play.rectangle.on.rectangle.fill"
                            )
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.darkBlue)
                            .padding(.trailing, 10)
                        }
                        .sheet(isPresented: $showTutorial) {
                            HIWTutorialPageView()
                        }

                        Button(action: {
                            openedFromPauseMenu = false
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.darkBlue)
                                .padding(.trailing, -5)
                        }
                        .accessibilityIdentifier("modeButton")
                    }

                    if isPlaying {
                        VStack {
                            // TODO: UPDATE PAUSE BUTTON FUNCTIONALITY
                            HStack {
                                Spacer()
                                Button(action: {
                                    showPauseMenu = true
                                    stopObstacleCycle()  //TODO: Pause the obstacle cycling
                                }) {
                                    Image(systemName: "pause.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.darkBlue)
                                        .padding()
                                }
                                .accessibilityIdentifier("pauseButton")
                            }

                            // Spacer to push VStack below the pause button
                            Spacer().frame(height: 20)  // Adjust the height as needed for spacing

                            //score,health,level
                            VStack {
                                // Score Section
                                HStack {
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: "Score",
                                            titleColor: .darkBlue, fontSize: 20)
                                    )
                                    .font(.headline)
                                    .bold()
                                    Spacer()
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: "\(score)",
                                            titleColor: .darkBlue, fontSize: 18)
                                    )
                                    .font(.body)
                                }

                                // Health Section
                                HStack {
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: "Health",
                                            titleColor: .darkBlue, fontSize: 20)
                                    )
                                    .font(.headline)
                                    .bold()
                                    Spacer()
                                    
                                    // Hearts for Health
                                    HStack(spacing: 5) {

                                        ForEach(0..<Int(maxHealth), id: \.self) { index in
                                            if index < Int(health) {
                                                Image(systemName: "heart.fill")
                                                    .foregroundColor(.darkBlue)
                                                    .font(.title2)
                                            } else {
                                                Image(systemName: "heart")
                                                    .foregroundColor(.darkBlue)
                                                    .font(.title2)
                                            }
                                        }
                                    }

//                                    CustomText(
//                                        config: CustomTextConfig(
//                                            text: "5",
//                                            titleColor: .darkBlue, fontSize: 18)
//                                    )
                                    .font(.body)
                                }



                                // Progress Section
                                HStack {
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: "Progress",
                                            titleColor: .darkBlue, fontSize: 20)
                                    )
                                    .font(.headline)
                                    .bold()
                                    Spacer()
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: "\(progress)",
                                            titleColor: .darkBlue, fontSize: 18)
                                    )
                                    .font(.body)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6).opacity(0.7))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }

                    } else {
                        //OFFICIAL exit button
                        Button(action: {
                            //completely stops audio player
                            isMuted = true
                            audioPlayer?.stop()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "x.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.darkBlue)
                                .padding()
                        }
                        .accessibilityIdentifier("exitButton")
                    }
                }
                Spacer()
            }

            if showSettings {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showSettings = false
                    }

                SettingsView(
                    showSettings: $showSettings, userId: userId, gameId: gameId,
                    selectedDifficulty: $selectedDifficulty,
                    showPauseMenu: $showPauseMenu,
                    openedFromPauseMenu: $openedFromPauseMenu,
                    isMuted: $isMuted,
                    audioPlayer: $audioPlayer
                )
                .frame(width: 300, height: 350)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .accessibilityIdentifier("settingsView")
            }

            if showTutorial {
                //HIWTutorialPageView()
            }

            if showPauseMenu {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPauseMenu = false
                    }

                PauseMenuView(
                    isPlaying: $isPlaying, showPauseMenu: $showPauseMenu,
                    showSettings: $showSettings,
                    showQuitConfirmation: $showQuitConfirmation,
                    openedFromPauseMenu: $openedFromPauseMenu,
                    isMuted: $isMuted,
                    audioPlayer: $audioPlayer
                )
                .frame(width: 300, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .accessibilityIdentifier("pauseMenuView")
                .onDisappear {
                    if isPlaying {
                        startObstacleCycle()  // Resume the obstacle cycling
                    }
                }
            }

            if isPlaying {
                HIWObstacleView(imageName: obstacles[obstacleIndex])
                    .animation(.linear(duration: 0), value: obstacleIndex)
                    .opacity(0.75) // Lower opacity
                    .allowsHitTesting(false)
            }

            if showCompletionScreen {
                CompletionScreenView(
                    levelNumber: currentLevel,
                    score: 100, // TODO: Replace with actual score logic
                    health: 5, // TODO: Replace with actual health logic
                    userId: userId,
                    isMuted: $isMuted,
                    audioPlayer: $audioPlayer,
                    onNextLevel: {
                        // Increment the level and reset the game state
                        currentLevel += 1
                        showCompletionScreen = false
                        isPlaying = false
                        stopObstacleCycle()  // Ensure the timer is stopped
                        startObstacleCycle()  // Restart the obstacle cycle for the next level
                    },
                    onQuitGame: {
                        // Logic for quitting the game
                        stopObstacleCycle()  // Ensure the timer is stopped
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            loadLevelImageMap()
            obstacles = levelImageMap[currentLevel] ?? []
            fetchGameSettings(userId: userId, gameId: gameId)
            loadAudio()
        }
        .onChange(of: currentLevel) { newLevel in
            // Update obstacles when the level changes
            obstacles = levelImageMap[newLevel] ?? []
            stopObstacleCycle()  // Stop any existing timer
            startObstacleCycle()  // Start the timer for the new level
        }
    }

    // load images from folder
    private func loadLevelImageMap() {
        for level in 1...5 {
            var imageNames: [String] = []
            for wall in 1...wallsPerLevel {
                let imageName = "level\(level)_wall\(wall)"
                imageNames.append(imageName)
            }
            levelImageMap[level] = imageNames
        }
    }

    private func startObstacleCycle() {
        stopObstacleCycle()  // Ensure no previous timer is running
        obstacleIndex = 0
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            checkCollisionOn = obstacles[obstacleIndex]
            obstacleIndex = (obstacleIndex + 1) % obstacles.count
            if obstacleIndex == 0 {
                // All obstacles have been cycled through
                stopObstacleCycle()
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                    showCompletionScreen = true
                }
            }
        }
    }

    private func stopObstacleCycle() {
        timer?.invalidate()
        timer = nil
    }

    func fetchGameSettings(userId: Int, gameId: Int) {
        guard
            let url = URL(
                string: APIHelper.getBaseURL()
                    + "/gameSettings?userId=\(userId)&gameId=\(gameId)")
        else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response from server")
                    return
                }

                if httpResponse.statusCode == 200, let data = data {
                    do {
                        let settings = try JSONDecoder().decode(
                            GameSettings.self, from: data)
                        if let difficulty = SettingsView.Difficulty(
                            rawValue: settings.difficulty)
                        {
                            self.selectedDifficulty = difficulty
                        } else {
                            self.selectedDifficulty = .normal
                            print("Invalid difficulty stored in server")
                        }
                    } catch {
                        print(
                            "Failed to decode JSON: \(error.localizedDescription)"
                        )
                    }
                } else {
                    self.fetchingError = true
                    print(
                        "Failed to fetch game settings. Status code: \(httpResponse.statusCode)"
                    )
                }
            }
        }.resume()
    }
}

func updateGameSettings(userId: Int, gameId: Int, diff: String) {
    guard let url = URL(string: APIHelper.getBaseURL() + "/gameSettings") else {
        print("Invalid URL")
        return
    }

    let body: [String: Any] = [
        "userId": String(userId),
        "gameId": String(gameId),
        "difficulty": diff,
    ]

    guard let jsonData = try? JSONSerialization.data(withJSONObject: body)
    else {
        print("Failed to encode JSON")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response from server")
                return
            }

            guard httpResponse.statusCode == 200 else {
                print(
                    "Failed to update game \(gameId) settings. Status code: \(httpResponse.statusCode)"
                )
                return
            }

            print("Game \(gameId) settings updated successfully!")
        }
    }.resume()
}

// the actual pop up stuff for settings
struct SettingsView: View {
    @Binding var showSettings: Bool
    var userId: Int
    var gameId: Int
    @Binding var selectedDifficulty: Difficulty
    @Binding var showPauseMenu: Bool
    @Binding var openedFromPauseMenu: Bool
    
    //audio stuff
    @Binding var isMuted: Bool
    @Binding var audioPlayer: AVAudioPlayer?
    
    @State private var isMusicMuted: Bool = false
//    @State private var isSoundEffectsMuted: Bool = false

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"

        var id: String { self.rawValue }
    }

    var body: some View {
        VStack(spacing: 15) {
            CustomHeader(config: .init(title: "Game Settings"))
                .accessibilityLabel("modeSelectionTitle")

            VStack {
                // Difficulty Picker
                Text("Difficulty")
                    .font(.headline)
                    .foregroundColor(.darkBlue)

                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 150)
                .background(Color.lightBlue)
                .cornerRadius(8)
                .accessibilityIdentifier("difficultyPicker")
                .onChange(of: selectedDifficulty) { newValue in
                    updateGameSettings(
                        userId: userId, gameId: gameId, diff: newValue.rawValue)
                }
            }

            // mute
            VStack(spacing: 15) {

                CustomButton(
                    config: CustomButtonConfig(
                        title: " ", //blank bc we have the mute symbols
                        width: 150,
                        buttonColor: .lightBlue,
                        action: {
                            // mute game from in game settings
                            toggleMusicMute(isMuted: isMuted, audioPlayer: audioPlayer)
                            isMuted.toggle()
                        })
                )
                .accessibilityIdentifier("muteMusicButton")
                .overlay(
                    HStack {
                        Image(
                            systemName: isMuted
                                ? "speaker.slash.fill" : "speaker.2.fill"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 20)
                        .foregroundColor(.white)
                        Text("Music")
                            .foregroundColor(.white)
                            .font(.body)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal)
                )

                // TODO: (temporarily removed sound effect button bc we dont need it rn) but ADD SOUND EFFECTS BACK AT SOME POINT
/*                CustomButton(
                    config: CustomButtonConfig(
                        title: " ",
                        width: 150,
                        buttonColor: .lightBlue,
                        action: {
                            isSoundEffectsMuted.toggle()
                            // actually will mute
                            toggleSoundEffectsMute(isMuted: isSoundEffectsMuted)
                        })
                )
                .accessibilityIdentifier("muteSoundEffectsButton")
                .overlay(
                    HStack {
                        Image(
                            systemName: isSoundEffectsMuted
                                ? "speaker.slash.fill" : "speaker.2.fill"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 22)
                        .foregroundColor(.white)
                        Text("Sound Effects")
                            .foregroundColor(.white)
                            .font(.body)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal)
                ) */
            }

            // Close Button
            CustomButton(
                config: CustomButtonConfig(
                    title: "Close", width: 150, buttonColor: .darkBlue,
                    action: {
                        showSettings = false
                        if openedFromPauseMenu {
                            showPauseMenu = true  // only reopen pause menu if settings were opened from it
                        }  // Reopen pause menu
                    })
            )
            .accessibilityIdentifier("closeButton")

            Spacer()
        }
        .padding()
    }

    // mutes music and updates toggle (through in game settings)
    private func toggleMusicMute(isMuted: Bool, audioPlayer: AVAudioPlayer?) {
        print("music \(isMuted ? "muted" : "unmuted")")
        if isMuted {
            print("Playing (togglemusicmute)")
            audioPlayer?.play()
        } else {
            print("Stop(togglemusicmute)")
            audioPlayer?.pause()
        }
    }

//    // TODO: add sound effects
//    private func toggleSoundEffectsMute(isMuted: Bool) {
//        print("sound effect \(isMuted ? "muted" : "unmuted")")
//    }
}

// pause menu
struct PauseMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPlaying: Bool  //checks if playing
    @Binding var showPauseMenu: Bool  // shows pause
    @Binding var showSettings: Bool  // shows settings
    @Binding var showQuitConfirmation: Bool  // shows quit confirmation
    @Binding var openedFromPauseMenu: Bool  //checks where settings was closed from
    
    //muting audio
    @Binding var isMuted: Bool
    @Binding var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 15) {

            CustomHeader(config: .init(title: "Game Paused"))
                .accessibilityIdentifier("pauseMenuTitle")

            CustomButton(
                config: CustomButtonConfig(
                    title: "Resume", width: 175, buttonColor: .lightBlue,
                    action: {
                        showPauseMenu = false
                    })
            )
            .accessibilityIdentifier("resumeButton")

            CustomButton(
                config: CustomButtonConfig(
                    title: "Game Settings", width: 175, buttonColor: .lightBlue,
                    action: {
                        openedFromPauseMenu = true
                        showSettings = true
                        showPauseMenu = false
                        
                    })
            )
            .accessibilityIdentifier("gameSettingsButton")

            CustomButton(
                config: CustomButtonConfig(
                    title: "Quit Game", width: 175, buttonColor: .darkBlue,
                    action: {
                        showQuitConfirmation = true
                    })
            )
            .accessibilityIdentifier("quitGameButton")
            .alert(
                "Are you sure you want to quit?",
                isPresented: $showQuitConfirmation
            ) {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {
                    presentationMode.wrappedValue.dismiss()
                    isPlaying = false
                    showPauseMenu = false
                    isMuted = true
                    audioPlayer?.stop()
                }
            }

            Spacer()
        }
        .padding()
    }
    // mutes music and updates toggle after quitting (through pause menu settings)
    private func toggleMusicMute(isMuted: Bool, audioPlayer: AVAudioPlayer?) {
        print("music \(isMuted ? "muted" : "unmuted")")
        if isMuted {
            print("Playing (quit game)")
            audioPlayer?.play()
        } else {
            print("Stop(quit game)")
            audioPlayer?.pause()
        }
    }
}

struct GameSettings: Codable {
    let user_id: Int
    let game_id: Int
    let difficulty: String
}

struct HIWObstacleView: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit) // Maintain aspect ratio and fit within the screen
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Take up all available space
            .clipped() // Ensure the image doesn't overflow outside its bounds
            .opacity(0.75) // Lower opacity
    }
}

//#Preview {
//    HIWGameLobbyView(userId: 421, gameId: 0)
//}
//#Preview {
//    HIWObstacleView(imageName: "wall1")
//}
