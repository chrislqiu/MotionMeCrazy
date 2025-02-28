//
//  SettingsPageView.swift
//  MotionMeCrazy
// Tea Lazareto 2/12/2025
//

import SwiftUI

struct SettingsPageView: View {
    @State private var audioLevel: Int = 50
    @State private var language: String = "EN"
    @State private var theme: String = "light"
    @State private var selectedTab: Int
    @ObservedObject var userViewModel: UserViewModel
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
//                HStack {
//                    TabButton(title: "Settings", isSelected: selectedTab == 0) {
//                        selectedTab = 0
//                    }
//                    TabButton(title: "Game Settings", isSelected: selectedTab == 1) {
//                        selectedTab = 1
//                    }
//                }
//                .padding()
                
                // Show settings content when "Settings" tab is selected
//                if selectedTab == 0 {
                settingsContent
//                } else {
//                    gameSettingsContent
//                }
            }
            .padding()
        }
        .onAppear {
            fetchAppSettings(userId: userViewModel.userid)
        }
    }
    
    var settingsContent: some View {
        VStack(spacing: 20) {
            CustomHeader(config: .init(title: "Settings"))
            
            // audio
            VStack(alignment: .leading) {
                CustomText(config: .init(text: "Audio Level"))
                Slider(value: $audioLevel, in: 0...100, step: 1)
                    .accentColor(.darkBlue)
                    .onChange(of: audioLevel) { newAudioLevel in
                        updateAppSettings(audio: newAudioLevel, lan: $language, theme: $theme)
                    }      
            }
            .padding()
            
            CustomButton(config: .init(title: "Change Theme", width: 200, buttonColor: .darkBlue, action: {updateAppSettings(audio: $audioLevel, lan: $language, theme: $theme)}) {})
            
            CustomButton(config: .init(title: "Change Language", width: 200, buttonColor: .darkBlue, action: {updateAppSettings(audio: $audioLevel, lan: $language, theme: $theme)}) {})
        }
    }
    
    func fetchAppSettings(userId: Int) {
        guard let url = URL(string: "http://localhost:3000/settings/appSettings?userId=\(userId)") else {
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
                        self.audioLevel = settings.audioLevel
                        self.language = settings.language
                        self.theme = settins.theme
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                    }
                } else {
                    print("Failed to fetch app settings. Status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }

    func updateAppSettings(audio: Int, lan: String, theme: String) {
        guard let url = URL(string: "http://localhost:3000/settings/appSettings") else {
            print("Invalid URL")
            return
        }

        let body: [String: Any] = [
            "userId": userViewModel.userid,
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

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response from server")
                    print("Failed to update app settings. Status code: \(httpResponse.statusCode)")
                    return
                }

                print("App settings updated successfully!")
            }
        }.resume()
    }

//    // idk if necessary
//    var gameSettingsContent: some View {
//        VStack(spacing: 20) {
//            CustomHeader(config: .init(title: "Game Settings"))
//            
//            // Placeholder
//            CustomText(config: .init(text: "Game Settings"))
//        }
//        .padding()
//    }
}

//struct TabButton: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text(title)
//                .font(.system(size: 18, weight: .bold))
//                .padding()
//                .background(isSelected ? Color(.darkBlue) : Color.clear) // Use darkBlue for selected background
//                .foregroundColor(isSelected ? .white : Color(.darkBlue)) // White text for selected, darkBlue for unselected
//                .border(isSelected ? Color.clear : Color(.darkBlue), width: 2) // darkBlue border for unselected
//                .cornerRadius(10)
//        }
//    }
//}

struct AppSettings: Codable {
    let userId: Int
    let audioLevel: Int
    let language: String
    let theme: String
}

#Preview {
    SettingsPageView()
}
