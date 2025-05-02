//
//  SettingsPageView.swift
//  MotionMeCrazy
//  Tea Lazareto 2/12/2025
//
import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case neon = "Neon"

    var id: String { self.rawValue }
}

enum Language: String, CaseIterable, Identifiable {
    case en = "EN" //reminding to update
    case es = "ES"
    case zh = "ZH"

    var id: String { self.rawValue }
}

enum GameMode: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case accessibility = "Accessibility"
    case random = "Random"
    
    var id: String {self.rawValue}
}

struct SettingsPageView: View {
    @State private var selectedAudioLevel: Double = 50
    @State var selectedTheme: Theme = .light
    @State var selectedLanguage: Language = .en
    @State var selectedGameMode: GameMode = .normal
    @State private var showThemePopup: Bool = false
    @State private var showLanguagePopup: Bool = false
    @State private var showGameModePopup: Bool = false
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState
    @State private var didFetchSettings = false
    
    var body: some View {
        ZStack {
            Image(appState.darkMode ? "background_dm" : "background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                settingsContent
            }
            .padding()
            
            if showThemePopup {
                ThemeSelectionPopup(showThemeOpt: $showThemePopup, userId: userViewModel.userid, audioLevel: selectedAudioLevel, theme: $selectedTheme, language: selectedLanguage, mode: selectedGameMode)
                    .transition(.scale)
            }
            if showLanguagePopup {
                LanguageSelectionPopup(showLangOpt: $showLanguagePopup, userId: userViewModel.userid, audioLevel: selectedAudioLevel, theme: selectedTheme, mode: selectedGameMode, language: $selectedLanguage)
                    .transition(.scale)
            }
            
            if showGameModePopup {
                GameModeSelectionPopup(showGameModeOpts: $showGameModePopup, userId: userViewModel.userid, audioLevel: selectedAudioLevel, theme: selectedTheme, language: selectedLanguage, mode: $selectedGameMode)
                    .transition(.scale)
            }
        }
        .onAppear {
            if !appState.offlineMode && !didFetchSettings {
                fetchAppSettings(userId: userViewModel.userid)
                didFetchSettings = true
            }
        }
        .animation(.easeInOut, value: showThemePopup) //transition for opening
        .animation(.easeInOut, value: showLanguagePopup) //transition for opening
    }
    
    //all the content presented on settings (MAIN) view
    var settingsContent: some View {
        VStack(spacing: 20) {
            CustomHeader(config: .init(title: appState.localized("Settings")))
            
            CustomButton(config: .init(title: appState.darkMode ? appState.localized("Light mode") : appState.localized("Dark mode"), width: 200, buttonColor: .darkBlue, action: { appState.darkMode = !appState.darkMode }))
                        
            CustomButton(config: .init(title: appState.localized("Change Theme"), width: 200, buttonColor: .darkBlue) {
                showThemePopup = true
            })
            
            CustomButton(config: .init(title: appState.localized("Change Mode"), width: 200, buttonColor: .darkBlue) {
                showGameModePopup = true
            })
            
            CustomButton(config: .init(title: appState.localized("Change Language"), width: 200, buttonColor: .darkBlue) {
                showLanguagePopup = true
                print("language: \(selectedLanguage)")
            })
        }
    }
    
    func fetchAppSettings(userId: Int) {
        
        guard let url = URL(string: APIHelper.getBaseURL() + "/appSettings?userId=\(userId)") else {
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
                        let settings = try JSONDecoder().decode(AppSettings.self, from: data)
                        self.selectedAudioLevel = settings.audio_level
                        if let theme = Theme(rawValue: settings.theme) {
                            self.selectedTheme = theme
                        } else {
                            print("Invalid theme stored in server")
                        }
                        if let language = Language(rawValue: settings.language) {
                            self.selectedLanguage = language

                        } else {
                            print("Invalid language stored in server")
                        }
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                    }
                } else {
                    print("Failed to fetch app settings. Status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}

func updateAppSettings(userId: Int, audio: Double, lan: String, theme: String, mode: String) {
    guard let url = URL(string: APIHelper.getBaseURL() + "/appSettings") else {
        print("Invalid URL")
        return
    }

    let body: [String: Any] = [
        "userId": userId,
        "audioLevel": audio,
        "language": lan,
        "theme": theme,
        "mode": mode,
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
                print("Failed to update app settings. Status code: \(httpResponse.statusCode)")
                return
            }

            print("App settings updated successfully!")
        }
    }.resume()
}

// pop up for theme selection (may just remove this completely later idk)
struct ThemeSelectionPopup: View {
    @Binding var showThemeOpt: Bool
    var userId: Int
    var audioLevel: Double
    @Binding var theme: Theme
    var language: Language
    var mode: GameMode
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                //exit
                Button(action: { showThemeOpt = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(appState.darkMode ? .white : .darkBlue)
                        .font(.title)
                }
            }
            
            CustomText(config: .init(text: appState.localized("Theme Options:")))
            
            VStack(spacing: 5) {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(
                        Image("background")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 50)
                            .clipped()
                    )
                    .frame(width: 120, height: 50)
                    .cornerRadius(10)
                

                CustomButton(config: .init(title: appState.localized("Default"), width: appState.currentLanguage == "EN" ? 120 : 175, buttonColor: .darkBlue) {
                    theme = .light
                    if !appState.offlineMode {
                        updateAppSettings(userId: userId, audio: audioLevel, lan: language.rawValue, theme: theme.rawValue, mode: mode.rawValue)
                    }
                })
            }
            .padding()
            .background(appState.darkMode ? .darkBlue.opacity(0.9) : Color.white.opacity(0.9))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding()
        .frame(width: 250)
        .background(appState.darkMode ? .darkBlue.opacity(0.95) : Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

//popup for language selection (also might remove this later, we will see)
struct LanguageSelectionPopup: View {
    @Binding var showLangOpt: Bool
    var userId: Int
    var audioLevel: Double
    var theme: Theme
    var mode: GameMode
    
    
    @Binding var language: Language
    @EnvironmentObject var appState: AppState
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                //exit
                Button(action: { showLangOpt = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(appState.darkMode ? .white : .darkBlue)
                        .font(.title)
                }
            }
            
            CustomText(config: .init(text: appState.localized("Language Options:")))
            
            CustomButton(config: .init(title: appState.localized("English"), width: 100, buttonColor: .darkBlue) {
                language = .en

                appState.currentLanguage = "EN"
                if !appState.offlineMode {
                    updateAppSettings(userId: userId, audio: audioLevel, lan: language.rawValue, theme: theme.rawValue, mode: mode.rawValue)
                }
                showLangOpt = false
            })

            CustomButton(config: .init(title: appState.localized("Spanish"), width: 100, buttonColor: .darkBlue) {
                language = .es
                appState.currentLanguage = "ES"
                if !appState.offlineMode {
                    updateAppSettings(userId: userId, audio: audioLevel, lan: language.rawValue, theme: theme.rawValue, mode: mode.rawValue)
                }
                showLangOpt = false
            })
        }
        .padding()
        .frame(width: 250)
        .background(appState.darkMode ? .darkBlue.opacity(0.95) : Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

//popup for game mode selection
struct GameModeSelectionPopup: View {
    @Binding var showGameModeOpts: Bool
    var userId: Int
    var audioLevel: Double
    var theme: Theme
    var language: Language
    @EnvironmentObject var appState: AppState
    @Binding var mode: GameMode

    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                //exit
                Button(action: { showGameModeOpts = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(appState.darkMode ? .white : .darkBlue)
                        .font(.title)
                }
            }
            
            CustomText(config: .init(text: appState.localized("Game Mode Options:")))
            
            CustomButton(config: .init(title: appState.localized("Normal"), width: 200, buttonColor: .darkBlue) {
                mode = .normal
                
                if !appState.offlineMode{
                    updateAppSettings(userId: userId, audio: audioLevel, lan: language.rawValue, theme: theme.rawValue, mode: mode.rawValue)
                }
            })
            
            CustomButton(config: .init(title: appState.localized("Accessibility"), width: 200, buttonColor: .darkBlue) {
                mode = .accessibility
                
                if !appState.offlineMode{
                    updateAppSettings(userId: userId, audio: audioLevel, lan: language.rawValue , theme: theme.rawValue, mode: mode.rawValue)
                }
            })
            
            CustomButton(config: .init(title: appState.localized("Random"), width: 200, buttonColor: .darkBlue) {
                mode = .random
                
                if !appState.offlineMode{
                    updateAppSettings(userId: userId, audio: audioLevel, lan: language.rawValue , theme: theme.rawValue, mode: mode.rawValue)
                }
            })
        }
        .padding()
        .frame(width: 250)
        .background(appState.darkMode ? .darkBlue.opacity(0.95) : Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}
struct AppSettings: Codable {
    let user_id: Int
    let audio_level: Double
    let theme: String
    let language: String
    let mode: String
}
//
//#Preview {
//    SettingsPageView(userViewModel: UserViewModel(userid: 421, username: "JazzyLegend633", profilePicId: "pfp2"))
//}
