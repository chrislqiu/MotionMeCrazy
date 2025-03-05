//
//  HIWGamePageView.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto on 2/13/25.
//
import SwiftUI

struct HIWGameLobbyView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showSettings = false  // shows settings pop up
    @State private var showPauseMenu = false  // shows pause menu pop up
    @State private var showQuitConfirmation = false // shows quit confirmation pop up
    @State private var showTutorial = false // show tutorial view
    @State private var isPlaying = false  // checks if game is active
    @State private var openedFromPauseMenu = false //checks where the settings was opened from
    @State private var selectedDifficulty: SettingsView.Difficulty = .normal  // Store difficulty here
    @State private var fetchingError: Bool = false
    var userId: Int
    var gameId: Int

    var body: some View {
        ZStack {
            ViewControllerView()
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
                            Image(systemName: "play.rectangle.on.rectangle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.darkBlue)
                                .padding(.trailing, 10)
                            
                        }
                        .sheet(isPresented: $showTutorial) {
                            HIWTutorialPageView()
                        }
                        
                        // the main settings button before you get into an active game
                        //only want this button when game not active
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
                        // pause button during gameplay
                        Button(action: {
                            showPauseMenu = true
                        }) {
                            Image(systemName: "pause.circle.fill")
                              .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.darkBlue)
                                .padding()
                        }
                        .accessibilityIdentifier("pauseButton")
                    } else {
                        // exit button thats present when ur on the game landing page thing
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()  //basically gets rid of this game view and returns to home
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

            // the actual game settings
            if showSettings {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showSettings = false
                    }

                SettingsView(showSettings: $showSettings, userId: userId, gameId: gameId, selectedDifficulty: $selectedDifficulty, showPauseMenu: $showPauseMenu, openedFromPauseMenu: $openedFromPauseMenu)
                    .frame(width: 300, height: 350)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .accessibilityIdentifier("settingsView")
            }
            
            // HIW game tutorial
            if showTutorial {
                //HIWTutorialPageView()
            }

            // pause menu for game
            if showPauseMenu {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPauseMenu = false
                    }

                PauseMenuView(
                    isPlaying: $isPlaying, showPauseMenu: $showPauseMenu,
                    showSettings: $showSettings, showQuitConfirmation: $showQuitConfirmation, openedFromPauseMenu: $openedFromPauseMenu
                )
                .frame(width: 300, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .accessibilityIdentifier("pauseMenuView")
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchGameSettings(userId: userId, gameId: gameId)
        }
        .onChange(of: fetchingError) { newValue in
            print("Updating game settings to default...")
            updateGameSettings(userId: userId, gameId: gameId, diff: selectedDifficulty.rawValue)
        }
    }
    
    func fetchGameSettings(userId: Int, gameId: Int) {
        guard let url = URL(string: "http://localhost:3000/gameSettings?userId=\(userId)&gameId=\(gameId)") else {
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
                        let settings = try JSONDecoder().decode(GameSettings.self, from: data)
                        if let difficulty = SettingsView.Difficulty(rawValue: settings.difficulty) {
                            self.selectedDifficulty = difficulty
                        } else {
                            self.selectedDifficulty = .normal
                            print("Invalid difficulty stored in server")
                        }
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                    }
                } else {
                    self.fetchingError = true
                    print("Failed to fetch game settings. Status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}

func updateGameSettings(userId: Int, gameId: Int, diff: String) {
    guard let url = URL(string: "http://localhost:3000/gameSettings") else {
        print("Invalid URL")
        return
    }

    let body: [String: Any] = [
        "userId": String(userId),
        "gameId": String(gameId),
        "difficulty": diff,
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
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response from server")
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("Failed to update game \(gameId) settings. Status code: \(httpResponse.statusCode)")
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
                    updateGameSettings(userId: userId, gameId: gameId, diff: newValue.rawValue)
                }
            }

            CustomButton(
                config: CustomButtonConfig(
                    title: "Setting 2", width: 150, buttonColor: .lightBlue
                ) {})
                .accessibilityIdentifier("setting2Button")

            CustomButton(
                config: CustomButtonConfig(
                    title: "Close", width: 150, buttonColor: .darkBlue,
                    action: {
                        showSettings = false
                        if openedFromPauseMenu {
                            showPauseMenu = true  // only reopen pause menu if settings were opened from it
                        }  // Reopen pause menu
                    }))
                .accessibilityIdentifier("closeButton")

            Spacer()
        }
        .padding()
    }
}


// pause menu
struct PauseMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isPlaying: Bool  //checks if playing
    @Binding var showPauseMenu: Bool  // shows pause
    @Binding var showSettings: Bool  // shows settings
    @Binding var showQuitConfirmation: Bool // shows quit confirmation
    @Binding var openedFromPauseMenu: Bool //checks where settings was closed from


    var body: some View {
        VStack(spacing: 15) {

            CustomHeader(config: .init(title: "Game Paused"))
                .accessibilityIdentifier("pauseMenuTitle")

            CustomButton(
                config: CustomButtonConfig(
                    title: "Resume", width: 175, buttonColor: .lightBlue,
                    action: {
                        showPauseMenu = false
                    }))
                .accessibilityIdentifier("resumeButton")

            CustomButton(
                config: CustomButtonConfig(
                    title: "Game Settings", width: 175, buttonColor: .lightBlue,
                    action: {
                        openedFromPauseMenu = true
                        showSettings = true
                        showPauseMenu = false
                    }))
                .accessibilityIdentifier("gameSettingsButton")

            CustomButton(
                config: CustomButtonConfig(
                    title: "Quit Game", width: 175, buttonColor: .darkBlue,
                    action: {
                        showQuitConfirmation = true
                    }))
                .accessibilityIdentifier("quitGameButton")
                .alert("Are you sure you want to quit?", isPresented: $showQuitConfirmation) {
                            Button("No", role: .cancel) { }
                            Button("Yes", role: .destructive) {
                                presentationMode.wrappedValue.dismiss()
                                isPlaying = false
                                showPauseMenu = false
                            }
                        }

            Spacer()
        }
        .padding()
    }
}

struct GameSettings: Codable {
    let user_id: Int
    let game_id: Int
    let difficulty: String
}

#Preview {
    HIWGameLobbyView(userId: 421, gameId: 0)
}
