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
    case en = "EN"
    case es = "ES"
    case zh = "ZH"

    var id: String { self.rawValue }
}

struct SettingsPageView: View {
    @State private var selectedAudioLevel: Double = 50
    @State var selectedTheme: Theme = .light
    @State var selectedLanguage: Language = .en
    @State private var showThemePopup: Bool = false
    @State private var showLanguagePopup: Bool = false
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                settingsContent
            }
            .padding()
            
            if showThemePopup {
                ThemeSelectionPopup(showThemeOpt: $showThemePopup, userId: userViewModel.userid, audioLevel: selectedAudioLevel, theme: $selectedTheme, language: selectedLanguage)
                    .transition(.scale)
            }
            if showLanguagePopup {
                LanguageSelectionPopup(showLangOpt: $showLanguagePopup, userId: userViewModel.userid, audioLevel: selectedAudioLevel, theme: selectedTheme, language: $selectedLanguage)
                    .transition(.scale)
            }
        }
        .onAppear() {
            fetchAppSettings(userId: userViewModel.userid)
        }
        .animation(.easeInOut, value: showThemePopup) //transition for opening
        .animation(.easeInOut, value: showLanguagePopup) //transition for opening
    }
    
    //all the content presented on settings (MAIN) view
    var settingsContent: some View {
        VStack(spacing: 20) {
            CustomHeader(config: .init(title: "Settings"))
            
            VStack(alignment: .leading) {
                CustomText(config: .init(text: "Audio Level"))
                Slider(
                    value: $selectedAudioLevel,
                    in: 0...100,
                    step: 1,
                    onEditingChanged: { editing in
                        if !editing {
                            updateAppSettings(userId: userViewModel.userid, audio: selectedAudioLevel, lan: selectedLanguage.rawValue, theme: selectedTheme.rawValue)
                        }
                    },
                    minimumValueLabel: Text("0"),
                    maximumValueLabel: Text("100"),
                    label: {
                        Text("Values from 0 to 100")
                    }
                )
                    .accentColor(.darkBlue)
                Text("\(selectedAudioLevel, specifier: "%.0f")")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            
            CustomButton(config: .init(title: "Change Theme", width: 200, buttonColor: .darkBlue) {
                showThemePopup = true
            })
            
            CustomButton(config: .init(title: "Change Language", width: 200, buttonColor: .darkBlue) {
                showLanguagePopup = true
            })
        }
    }
    
    func fetchAppSettings(userId: Int) {
        guard let url = URL(string: "http://localhost:3000/appSettings?userId=\(userId)") else {
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

func updateAppSettings(userId: Int, audio: Double, lan: String, theme: String) {
    guard let url = URL(string: "http://localhost:3000/appSettings") else {
        print("Invalid URL")
        return
    }

    let body: [String: Any] = [
        "userId": userId,
        "audioLevel": audio,
        "language": lan,
        "theme": theme,
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
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                //exit
                Button(action: { showThemeOpt = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
            }
            
            CustomText(config: .init(text: "Theme Options:"))
            
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
                
                CustomButton(config: .init(title: "Default", width: 150, buttonColor: .darkBlue) {
                    theme = .light
                    updateAppSettings(userId: userId, audio: audioLevel, lan: language.rawValue, theme: theme.rawValue)
                })
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding()
        .frame(width: 250)
        .background(Color.white.opacity(0.95))
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
    @Binding var language: Language
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                //exit
                Button(action: { showLangOpt = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                }
            }
            
            CustomText(config: .init(text: "Language Options:"))
            
            CustomButton(config: .init(title: "English", width: 100, buttonColor: .darkBlue) {
                language = .en
                updateAppSettings(userId: userId, audio: audioLevel, lan: language.rawValue , theme: theme.rawValue)
            })
        }
        .padding()
        .frame(width: 250)
        .background(Color.white.opacity(0.95))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct AppSettings: Codable {
    let user_id: Int
    let audio_level: Double
    let theme: String
    let language: String
}

#Preview {
    SettingsPageView(userViewModel: UserViewModel(userid: 421, username: "JazzyLegend633", profilePicId: "pfp2"))
}
