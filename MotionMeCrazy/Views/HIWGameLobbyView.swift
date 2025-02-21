import SwiftUI

struct HIWGameLobbyView: View {

    @Environment(\.presentationMode) var presentationMode
    @State private var showSettings = false  // shows settings pop up
    @State private var showPauseMenu = false  // shows pause menu pop up
    @State private var isPlaying = false  // checks if game is active
    @State private var selectedDifficulty: SettingsView.Difficulty = .normal  // Store difficulty here

    var body: some View {
        ZStack {
            CameraPreview()

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

                    // the main settings button before you get into an active game
                    //only want this button when game not active
                    if !isPlaying {
                        Button(action: {
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

                SettingsView(showSettings: $showSettings, selectedDifficulty: $selectedDifficulty)
                    .frame(width: 300, height: 350)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .accessibilityIdentifier("settingsView")
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
                    showSettings: $showSettings
                )
                .frame(width: 300, height: 300)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
                .accessibilityIdentifier("pauseMenuView")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// the actual pop up stuff for settings
struct SettingsView: View {
    @Binding var showSettings: Bool
    @Binding var selectedDifficulty: Difficulty  // Corrected binding

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"

        var id: String { self.rawValue }
    }

    var body: some View {
        VStack(spacing: 15) {
            CustomHeader(config: .init(title: "Game Settings"))
            //idk what to put here still
            // Difficulty Dropdown
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
                .pickerStyle(MenuPickerStyle())  // Makes it a dropdown menu
                .frame(width: 150)
                .background(Color.lightBlue)
                .cornerRadius(8)
                .accessibilityIdentifier("difficultyPicker")
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
                    }))
                .accessibilityIdentifier("closeButton")

            Spacer()
        }
        .padding()
    }
}

// pause menu
struct PauseMenuView: View {
    @Binding var isPlaying: Bool  //checks if playing
    @Binding var showPauseMenu: Bool  // shows pause
    @Binding var showSettings: Bool  // shows settings

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
                        showSettings = true
                        showPauseMenu = false
                    }))
                .accessibilityIdentifier("gameSettingsButton")

            CustomButton(
                config: CustomButtonConfig(
                    title: "Quit Game", width: 175, buttonColor: .darkBlue,
                    action: {
                        isPlaying = false
                        showPauseMenu = false
                    }))
                .accessibilityIdentifier("quitGameButton")

            Spacer()
        }
        .padding()
    }
}

#Preview {
    HIWGameLobbyView()
}
