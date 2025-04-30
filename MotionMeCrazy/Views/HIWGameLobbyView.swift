import SwiftUI
import AVFoundation

struct HIWGameLobbyView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showSettings = false
    @State private var showPauseMenu = false
    @State private var showScoringInfo = false
    @State private var showQuitConfirmation = false
    @State private var showTutorial = false
    @State private var isPlaying = false
    @State private var openedFromPauseMenu = false
    @State private var selectedDifficulty: SettingsView.Difficulty = .normal
    @State private var selectedTheme: SettingsView.Theme = .basic
    @State private var selectedMode: SettingsView.GameMode = .normal
    @State private var fetchingError: Bool = false
    @State private var obstacleIndex = 0
    @State private var timer: Timer? = nil
    @State private var showCompletionScreen = false
    @State private var showFailureScreen = false
    
    //TODO: ADD FUNCTIONALITY game stats
    @State private var endOfLevel = false
    @State private var score: Int = 0  //TODO: Adjust
    @State private var health: Double = 5  //TODO: Adjust
    @State private var maxHealth: Double = 5  //TODO: Adjust
    @State private var currentLevel = 1
    @State private var totalLevelCollisions: Int = 0
    @State private var scoredImages: Set<String> = []
    
    @State private var obstacles: [String] = []
    @State private var levelImageMap: [Int: [String]] = [:]
    @State private var checkCollisionOn: String!
    @StateObject private var countdownManager = CountdownManager()
    @State private var isPaused = false
    @State private var savedObstacleIndex = 0
    @State private var countdownWasActive = false
    @State private var showEndGameScreen = false
    
    //Sound stuff
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isMuted = false
    @State private var soundEffectPlayer: AVAudioPlayer?
    @State private var isSoundEffectMuted = false

    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var webSocketManager: WebSocketManager
    

    @EnvironmentObject var appState: AppState


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
    
    //Loading audio
    func loadSoundEffect() {
        //getting royalty free song lol
        guard let url = Bundle.main.url(forResource: "vine-boom", withExtension: "mp3") else {
            print("sound not found.")
            return
        }
        
        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.prepareToPlay()
            print("sound effect loaded")

        } catch {
            print("audio file loading fail: \(error)")
        }
    }
    

    //@State private var progress: String = "Level 1/10"

    private let wallsPerLevel = 4  // Number of walls per level

    var userId: Int
    var gameId: Int

    var body: some View {
        ZStack {
            // 1. Game Background
            ViewControllerView(obstacleImageName: $checkCollisionOn) { imageName, collisionCount in
                DispatchQueue.main.async {
                   // if self.isPlaying && !self.countdownManager.isActive {
                    print("imageName initial \(imageName)")
                        guard !self.scoredImages.contains(imageName) else {
                                return // already scored this image, skip
                            }
                    
                       self.scoredImages.insert(imageName)
                        // makes sure that score doesn't go in the negatives
                        print("collisionCount \(collisionCount) for \(imageName)")
                        if self.score > 0 {
                            //if it exceeds 20, just subtract 1000 points
                            if collisionCount >=  20 {
                                self.score = max(self.score - 1000, 0)
                            } else {
                            //if its below 20, each collision deducts 50 points
                                self.score = max(self.score - (collisionCount * 50), 0)
                            }
                        }
                        // count total collisions for the level
                        self.totalLevelCollisions += collisionCount
                        
                        //remember collision count is just for the image
                        //if there are more than 20 collisions detected, deduct a health point
                        if collisionCount >= 20 {
                            self.health = max(self.health - 1, 0)
                        } else {
                            print("currentLevel \(self.currentLevel)")
                            print("image \(imageName), score \(self.score)")
                            self.score += 1000
                        }
                        
                        // if there are less than 20 collisions in total on all obstacles in this level, give bonus which is the level number * 1000
                        print("endOfLevel: \(self.endOfLevel)")
                        if self.endOfLevel {
                            if totalLevelCollisions < 20 {
                                self.score += (self.currentLevel * 1000)
                            }
                            
                            totalLevelCollisions = 0
                            self.scoredImages.removeAll()
                        }
                        print("score after calc \(self.score)")
                    
                   // }
                 
                }
                
            }
                .edgesIgnoringSafeArea(.all)

            // 2. Obstacle View
            if isPlaying && !countdownManager.isActive {
                if obstacleIndex >= 0 && obstacleIndex < obstacles.count {
                    HIWObstacleView(imageName: obstacles[obstacleIndex])
                        .animation(.linear(duration: 0), value: obstacleIndex)
                        .opacity(0.75)
                        .allowsHitTesting(false)
                }
            }

            // 3. Start/Play Button
            VStack(spacing: 50) {
                if !isPlaying {
                    CustomHeader(config: .init(title: appState.localized("Hole in the Wall")))
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
            .onChange(of: isPlaying) { checkIsPlaying in
                // When isPlaying state changes to false, stop the obstacle cycle
                if !checkIsPlaying {
                    stopObstacleCycle()
                }
            }

            // 4. Top-right Controls, Score/Health/Progress
            VStack {
                HStack {
                    Spacer()

                    if !isPlaying {
                        Button(action: {
                            showScoringInfo = true
                            stopObstacleCycle() //added just for safety
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .foregroundColor(.darkBlue)
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 10)
                        }
                        
                        Button(action: {
                            showTutorial = true
                            stopObstacleCycle() //also added just for safety
                        }) {
                            Image(systemName: "play.rectangle.on.rectangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.darkBlue)
                                .padding(.trailing, 10)
                        }
                        .sheet(isPresented: $showTutorial) {
                            HIWTutorialPageView(userViewModel: userViewModel)
                        }

                        Button(action: {
                            openedFromPauseMenu = false
                            showSettings = true
                            stopObstacleCycle() //added
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
                            HStack {
                                Spacer()
                                Button(action: {
                                    showPauseMenu = true
                                    isPaused = true
                                    savedObstacleIndex = obstacleIndex
                                    countdownWasActive = countdownManager.isActive
                                    stopObstacleCycle()
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

                            Spacer().frame(height: 20)

                            VStack {
                                HStack {
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: appState.localized("Score"),
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

                                HStack {
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: appState.localized("Health"),
                                            titleColor: .darkBlue, fontSize: 20)
                                    )
                                    .font(.headline)
                                    .bold()
                                    Spacer()

                                    HStack(spacing: 5) {
                                        ForEach(0..<Int(maxHealth), id: \.self) { index in
                                            if index < Int(health) {
                                                Image(systemName: "heart.fill")
                                                    .foregroundColor(appState.darkMode ? .white : .darkBlue)
                                                    .font(.title2)
                                            } else {
                                                Image(systemName: "heart")
                                                    .foregroundColor(.darkBlue)
                                                    .font(.title2)
                                            }
                                        }
                                    }
                                    .font(.body)
                                }

                                HStack {
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: appState.localized("Progress"),
                                            titleColor: .darkBlue, fontSize: 20)
                                    )
                                    .font(.headline)
                                    .bold()
                                    Spacer()
                                    CustomText(
                                        config: CustomTextConfig(
                                            text: "\(currentLevel)/\(5)",
                                            titleColor: .darkBlue, fontSize: 18)
                                    )
                                    .font(.body)
                                }

                                // Players' Scores Section (WebSocket Data)
                                
                            }
                            .padding()
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            VStack(alignment: .leading, spacing: 4) {  // Reduced spacing between player scores
                                ForEach(webSocketManager.lobbyPlayers) { player in
                                    HStack {
                                        Text(player.username)
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.white)

                                        Spacer()

                                        HStack(spacing: 4) {
                                            Text("⭐️ \(player.score)")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                            Text("❤️ \(player.health)")
                                                .font(.caption2)
                                                .foregroundColor(.white)

                                           
                                        }
                                    }
                                    .padding(.horizontal, 8)
                                    .frame(maxHeight: 20)
                                }

                                            
                                        }
                                        .padding(8)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(10)
                                        .padding()
                                        .frame(maxWidth: 400, alignment: .topLeading)
                                        .fixedSize(horizontal: false, vertical: true)
                        }
                    } else {
                        Button(action: {
                            isMuted = true
                            isSoundEffectMuted = true
                            soundEffectPlayer?.stop()
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

            // 5. Countdown Overlay
            if isPlaying && countdownManager.isActive {
                CountdownView(value: countdownManager.value)
            }

            // 6. Settings View
            if showSettings {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showSettings = false
                    }

                SettingsView(
                    showSettings: $showSettings, userId: userId, gameId: gameId,
                    selectedDifficulty: $selectedDifficulty,
                    selectedTheme: $selectedTheme,
                    selectedMode: $selectedMode,
                    showPauseMenu: $showPauseMenu,
                    openedFromPauseMenu: $openedFromPauseMenu,
                    isMuted: $isMuted,
                    audioPlayer: $audioPlayer,
                    isSoundEffectsMuted: $isSoundEffectMuted
                )
                .frame(width: 300, height: 450)
                .background(appState.darkMode ? .darkBlue : Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .accessibilityIdentifier("settingsView")
                .onDisappear {
                    loadLevelImageMap()
                    obstacles = levelImageMap[currentLevel] ?? []
                    fetchGameSettings(userId: userId, gameId: gameId)
                }
                .onChange(of: showSettings) { updatedShowSettings in
                    if updatedShowSettings {
                        stopObstacleCycle()
                        if openedFromPauseMenu {
                            savedObstacleIndex = obstacleIndex
                        }
                    }
                }
            }
            //6.5 Scoring info
            if showScoringInfo {
                ScoringInfoPopupView(showScoringInfo: $showScoringInfo)
                    .background(appState.darkMode ? .darkBlue : Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .transition(.scale)
                    .zIndex(1)
                    .frame(width: 300, height: 450)
            }

            // 7. Pause Menu View
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
                    audioPlayer: $audioPlayer,
                    soundEffectPlayer: $soundEffectPlayer,
                    isSoundEffectMuted: $isSoundEffectMuted,
                    startObstacleCycle: startObstacleCycle
                    
                )
                .frame(width: 300, height: 300)
                .background(appState.darkMode ? .darkBlue : Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .accessibilityIdentifier("pauseMenuView")
                .onDisappear {
                    if isPlaying && isPaused  {
                        isPaused = false
                        //print("showSettings: \(showSettings)")
                        //print("openedFromPauseSettings: \(openedFromPauseMenu)")
                        if !showSettings && !openedFromPauseMenu {
                            startObstacleCycle(resumeFromPause: true)
                        }
                    }
                }
            }

            // 8. Completion Screen
            if showCompletionScreen {
                CompletionScreenView(
                    levelNumber: currentLevel,
                    totalLevels: 5,
                    score: score,
                    health: health,
                    userId: userId,
                    isMuted: $isMuted,
                    audioPlayer: $audioPlayer,
                    onNextLevel: {
                        currentLevel += 1
                        showCompletionScreen = false
                        endOfLevel = false
                        isPlaying = false
                        stopObstacleCycle()
                        //startObstacleCycle()
                    },
                    onQuitGame: {
                        stopObstacleCycle()
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
            
            // 9. End Game Screen
            if showFailureScreen {
                FailedLevelScreenView(
                    levelNumber: currentLevel,
                    totalLevels: 5,
                    score: score,
                    health: health,
                    onRetryLevel: {
                        showFailureScreen = false
                        isPlaying = false
                        stopObstacleCycle()
                        health += 3
                        //startObstacleCycle()
                    },
                    onQuitGame: {
                        stopObstacleCycle()
                        presentationMode.wrappedValue.dismiss()
                    },
                    isMuted: $isMuted,
                    audioPlayer: $audioPlayer
                )
                    
            }
            
            // 10. End Game Screen
            if showEndGameScreen {
                EndGameScreenView(
                    levelNumber: 5,  // Final level
                    totalLevels: 5,  // Total levels
                    score: score,
                    health: health,
                    userId: userId,
                    isMuted: $isMuted,
                    audioPlayer: $audioPlayer,
                    onNextLevel: { },
                    onQuitGame: {
                        stopObstacleCycle()
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
            loadSoundEffect()
            loadAudio()
        }
        .onChange(of: currentLevel) { newLevel in
            obstacles = levelImageMap[newLevel] ?? []
            stopObstacleCycle()
            //startObstacleCycle()
        }
        .onChange(of: selectedDifficulty) { newDifficulty in
            loadLevelImageMap()
            obstacles = levelImageMap[currentLevel] ?? []
        }
    }


    // load images from folder
    private func loadLevelImageMap() {
        // Clear any existing mappings
        levelImageMap.removeAll()
        
        if selectedMode == .normal {
            
            // Load images based on difficulty
            for level in 1...5 {
                levelImageMap[level] = generateWallsForLevel(level, difficulty: selectedDifficulty)
            }
        } else if selectedMode == .accessibility {
            //TODO: LOAD ACCESSIBILITY IMAGES
            
        } else if selectedMode == .random {

            var allWallsPool: [String] = []
            
            // Add walls from both difficulties
            for level in 1...5 {
                allWallsPool += generateWallsForLevel(level, difficulty: .easy)
                allWallsPool += generateWallsForLevel(level, difficulty: .hard)
            }
            
            for level in 1...5 {
                levelImageMap[level] = Array(allWallsPool.shuffled().prefix(wallsPerLevel))
            }
        }
    }
    
    private func generateWallsForLevel(_ level: Int, difficulty: SettingsView.Difficulty) -> [String] {
        let difficultySuffix = difficulty == .easy ? "e" : "h"
        let themeSuffix = themeSuffix(for: selectedTheme)
        var walls: [String] = []
        
        for wall in 1...wallsPerLevel {
            walls.append("level\(level)_wall\(wall)\(difficultySuffix)\(themeSuffix)")
        }
        
        return walls
    }

    private func themeSuffix(for theme: SettingsView.Theme) -> String {
        switch theme {
        case .basic: return ""
        case .light: return "_lm"
        case .dark: return "_dm"
        }
    }

    private func startObstacleCycle(resumeFromPause: Bool = false) {
        stopObstacleCycle()  // Ensure no previous timers are running
        
        if resumeFromPause && !countdownWasActive {
            print("resume countdown")
            // Resume from where we left off (skip countdown if it wasn't active)
            obstacleIndex = savedObstacleIndex
            
            // Create a non-repeating timer that shows each obstacle and schedules the next one
            scheduleNextObstacle()
        } else {
            // Normal start (with countdown)
            print("Start countdown")
            obstacleIndex = 0
            
            // Start the countdown
            countdownManager.start {
                // This code runs when countdown completes
                // Start showing obstacles one by one
                self.scheduleNextObstacle()
            }
        }
    }
    
    private func scheduleNextObstacle() {
        //if health reaches 0 before level is over, show failure screen
        if health == 0 {
          stopObstacleCycle()
          showFailureScreen = true
            if self.score >= 4000 {
                score -= 4000
            }
          return
        }
        
        // If we've gone through all obstacles or have an invalid index, show completion screen
        if (obstacleIndex < 0 && health > 0) || (obstacleIndex >= obstacles.count) {
            // Safety check: ensure we stop any running timers
            stopObstacleCycle()
            
            if currentLevel >= 5 {
                showEndGameScreen = true
            } else {
                showCompletionScreen = true
                endOfLevel = true
            }
            return
        }
        
        // Show current obstacle
        checkCollisionOn = obstacles[obstacleIndex]
        if !isSoundEffectMuted {
                self.soundEffectPlayer?.stop()
                self.soundEffectPlayer?.currentTime = 0
                self.soundEffectPlayer?.prepareToPlay()
                
                self.soundEffectPlayer?.play()

                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                    self.soundEffectPlayer?.stop()  // Stop the audio after 1 second
                }
            } else {
                self.soundEffectPlayer?.stop()
            }
        
        // Schedule the next one after a delay
        var difficultyTimer = 1.5
        if (selectedMode != .random) {
            difficultyTimer = selectedDifficulty == .easy ? 3.0 : 1.0
        }
        timer = Timer.scheduledTimer(withTimeInterval: difficultyTimer, repeats: false) { _ in
            updateScore(lobbyCode: webSocketManager.lobbyCode, userId: userViewModel.userid, score: score, health: Int(health))
            print(self.obstacleIndex)
            if !isSoundEffectMuted {
                    self.soundEffectPlayer?.stop()
                    self.soundEffectPlayer?.currentTime = 0
                    self.soundEffectPlayer?.prepareToPlay()
                    
                    self.soundEffectPlayer?.play()

                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                        self.soundEffectPlayer?.stop()  // Stop the audio after 1 second
                    }
                } else {
                    self.soundEffectPlayer?.stop()
                }

            //print(isSoundEffectMuted)
            self.obstacleIndex += 1
            self.scheduleNextObstacle()
        }
    }
    
    private func stopObstacleCycle() {
        // Invalidate any active timer
        timer?.invalidate()
        timer = nil
        
        // Stop countdown if active
        countdownManager.stop()
        print("timer stopped")
        getAllScores(lobbyCode: webSocketManager.lobbyCode, webSocketManager: webSocketManager)
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
                            // Reload level images when difficulty is set
                            self.loadLevelImageMap()
                            self.obstacles = self.levelImageMap[self.currentLevel] ?? []
                        } else {
                            self.selectedDifficulty = .normal
                            print("Invalid difficulty stored in server")
                        }
                        
                        if let theme = SettingsView.Theme(
                            rawValue: settings.theme)
                        {
                            self.selectedTheme = theme
                            print(self.selectedTheme)
                        } else {
                            self.selectedTheme = .basic
                            print("Invalid theme stored in server")
                        }
                        
                        // fetching game mode
                        if let mode = SettingsView.GameMode(rawValue: settings.mode) {
                            self.selectedMode = mode
                            print(self.selectedMode)
                        } else {
                            self.selectedMode = .normal
                            print("Invalid mode stored in server")
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

func updateGameSettings(userId: Int, gameId: Int, diff: String, theme: String, mode: String) {
    guard let url = URL(string: APIHelper.getBaseURL() + "/gameSettings") else {
        print("Invalid URL")
        return
    }

    let body: [String: Any] = [
        "userId": String(userId),
        "gameId": String(gameId),
        "difficulty": diff,
        "theme": theme,
        "mode": mode
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
    @Binding var selectedTheme: Theme
    @Binding var selectedMode: GameMode
    @Binding var showPauseMenu: Bool
    @Binding var openedFromPauseMenu: Bool
    
    //audio stuff
    @Binding var isMuted: Bool
    @Binding var audioPlayer: AVAudioPlayer?
    @Binding var isSoundEffectsMuted: Bool
    
    //@State private var showThemeDialog = false
    //@State private var selectedTheme: String? = nil
    @State private var isMusicMuted: Bool = false

    
    @EnvironmentObject var appState: AppState

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"

        var id: String { self.rawValue }
    }
    
    enum Theme: String, CaseIterable, Identifiable {
        case basic = "Basic"
        case light = "Light"
        case dark = "Dark"

        var id: String { self.rawValue }
    }
    
    enum GameMode: String, CaseIterable, Identifiable {
        case normal = "Normal"
        case accessibility = "Accessibility"
        case random = "Random"

        var id: String { self.rawValue }
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                CustomHeader(config: .init(title: appState.localized("Game Settings")))
                    .accessibilityLabel("modeSelectionTitle")
                
                VStack {
                    // Difficulty Picker
                    CustomText(config: .init(text: appState.localized("Difficulty")))
                    
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
                            userId: userId, gameId: gameId, diff: newValue.rawValue, theme: selectedTheme.rawValue, mode: selectedMode.rawValue)
                        
                    }
                    
                    // Theme Picker
                    CustomText(config: .init(text: appState.localized("Themes")))
                    
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 150)
                    .background(Color.lightBlue)
                    .cornerRadius(8)
                    .accessibilityIdentifier("themePicker")
                    .onChange(of: selectedTheme) { newValue in
                        updateGameSettings(
                            userId: userId, gameId: gameId, diff: selectedDifficulty.rawValue, theme: newValue.rawValue, mode: selectedMode.rawValue)
                    }
                    
                    // Mode Picker
                    CustomText(config: .init(text: appState.localized("Modes")))
                    
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(GameMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 150)
                    .background(Color.lightBlue)
                    .cornerRadius(8)
                    .accessibilityIdentifier("modePicker")
                    .onChange(of: selectedMode) { newValue in
                        updateGameSettings(
                            userId: userId, gameId: gameId, diff: selectedDifficulty.rawValue, theme: newValue.rawValue, mode: selectedMode.rawValue)
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
                            Text(appState.localized("Music"))
                                .foregroundColor(.white)
                                .font(.body)
                                .font(.system(size: 16))
                        }
                            .padding(.horizontal)
                    )
                    
                    // TODO: (temporarily removed sound effect button bc we dont need it rn) but ADD SOUND EFFECTS BACK AT SOME POINT
                    CustomButton(
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
                            Text(appState.localized("Sound Effects"))
                                .foregroundColor(.white)
                                .font(.body)
                                .font(.system(size: 16))
                        }
                            .padding(.horizontal)
                    )
                }
                
                // Close Button
                CustomButton(
                    config: CustomButtonConfig(
                        title: appState.localized("Close"), width: 150, buttonColor: .darkBlue,
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

   
    private func toggleSoundEffectsMute(isMuted: Bool) {
        print("sound effect \(isMuted ? "muted" : "unmuted")")
    }
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
    @Binding var soundEffectPlayer: AVAudioPlayer?
    @Binding var isSoundEffectMuted: Bool
    var startObstacleCycle: (Bool) -> Void
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 15) {

            CustomHeader(config: .init(title: appState.localized("Game Paused")))
                .accessibilityIdentifier("pauseMenuTitle")

            CustomButton(
                config: CustomButtonConfig(
                    title: appState.localized("Resume"), width: 175, buttonColor: .lightBlue,
                    action: {
                        showSettings = false
                        openedFromPauseMenu = false
                        showPauseMenu = false
                        startObstacleCycle(true) 
                    })
            )
            .accessibilityIdentifier("resumeButton")

            CustomButton(
                config: CustomButtonConfig(
                    title: appState.localized("Game Settings"), width: 175, buttonColor: .lightBlue,
                    action: {
                        openedFromPauseMenu = true
                        showSettings = true
                        showPauseMenu = false
                    })
            )
            .accessibilityIdentifier("gameSettingsButton")

            CustomButton(
                config: CustomButtonConfig(
                    title: appState.localized("Quit Game"), width: 175, buttonColor: .darkBlue,
                    action: {
                        showQuitConfirmation = true
                    })
            )
            .accessibilityIdentifier("quitGameButton")
            .alert(
                appState.localized("Are you sure you want to quit?"),
                isPresented: $showQuitConfirmation
            ) {
                Button(appState.localized("No"), role: .cancel) {}
                Button(appState.localized("Yes"), role: .destructive) {
                    presentationMode.wrappedValue.dismiss()
                    isPlaying = false
                    showPauseMenu = false
                    showSettings = false
                    openedFromPauseMenu = false
                    isMuted = true
                    isSoundEffectMuted = true
                    soundEffectPlayer?.stop()
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

//popup that explains how scoring works
struct ScoringInfoPopupView: View {
    @Binding var showScoringInfo: Bool
    @EnvironmentObject var appState: AppState
    @State private var selectedInfoIndex: Int = 0

    private let scoringMessages = [
        "Each ❌ shows where you 'hit' the wall. Each hit is -50 points.",
        "Every time you clear a wall with less than 20 hits, +1000 points",
        "For every level where you hit all walls less than 20 times total, you get a bonus of 1000 × the level number"
    ]

    var body: some View {
        if showScoringInfo {
            ZStack {
                VStack(spacing: 20) {
                    CustomHeader(config: .init(title: appState.localized("Scoring")))
                        .accessibilityLabel("scoringExplain")
                    
                    CustomText(config: .init(text: appState.localized(scoringMessages[selectedInfoIndex]), fontSize: 18))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 8) {
                        ForEach(0..<scoringMessages.count, id: \.self) { index in
                            CustomButton(config: CustomButtonConfig(
                                title: "\(index + 1)",
                                width: 40,
                                buttonColor: selectedInfoIndex == index ? .darkBlue : .lightBlue.opacity(0.7),
                                action: {
                                    selectedInfoIndex = index
                                },
                                titleColor: .white,
                                fontSize: 18
                            ))
                            .frame(height: 40)
                        }
                    }


                    // Close Button
                    CustomButton(
                        config: CustomButtonConfig(
                            title: appState.localized("Close"), width: 150, buttonColor: .darkBlue,
                            action: {
                                showScoringInfo = false
                            })
                    )
                    .accessibilityIdentifier("closeButton")
                }
                .padding()
                .frame(width: 300)
                .background(appState.darkMode ? Color.darkBlue : Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
            }
        }
    }
}

struct GameSettings: Codable {
    let user_id: Int
    let game_id: Int
    let difficulty: String
    let theme: String
    let mode: String
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


func updateScore(lobbyCode: String, userId: Int, score: Int, health: Int) {
    guard let url = URL(string: APIHelper.getBaseURL() + "/update-score") else {
        print("Invalid URL")
        return
    }

    let body: [String: Any] = [
        "code": lobbyCode,
        "userId": userId,
        "score": score,
        "health": health
    ]

    guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
        print("Failed to encode JSON")
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    URLSession.shared.dataTask(with: request) { data, response, error in
        DispatchQueue.main.async {
            if error != nil {
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("Score successfully updated!")
                } else {
                    print("Score failed")

                }
            }
        }
    }.resume()
}


func getAllScores(lobbyCode: String, webSocketManager: WebSocketManager) {

    guard let url = URL(string: APIHelper.getBaseURL() + "/get-scores/\(lobbyCode)") else {
        print("Invalid URL")
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
        DispatchQueue.main.async {
            if error != nil {
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            let players = try JSONDecoder().decode([LobbyPlayer].self, from: data)
                            webSocketManager.lobbyPlayers = players
                            print(players)
                        } catch {
                            print(error)
                        }
                    }
                } else {
                }
            }
        }
    }.resume()
}
