import SwiftUI
import AVFoundation
//
//  EndGameScreenView.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 4/22/25.
//

struct EndGameScreenView: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    @ObservedObject var userViewModel: UserViewModel


    //@State private var showQuitConfirmation = false // shows quit
    @State private var errorMessage: String?
    var levelNumber: Int
    var totalLevels: Int
    var score: Int
    var health: Double
    var userId: Int
    var timePlayed: TimeInterval
    @Binding var isMuted: Bool
    @Binding var audioPlayer: AVAudioPlayer?
    var onNextLevel: () -> Void
    var onQuitGame: () -> Void

    
    //audio stuff
    
    
        var body: some View {
            ZStack {
                // darkened background overlay
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // prevent accidental dismiss
                    }

                VStack(spacing: 20) {
                    CustomHeader(config: .init(title: String(format: appState.localized("Level %d/%d Completed!"), levelNumber, totalLevels), fontSize: 26))

                    VStack(spacing: 10) {
                        CustomText(config: CustomTextConfig(text: String(format: appState.localized("Score: %d"),score), fontSize:20))
                        CustomText(config:CustomTextConfig(text: String(format: appState.localized("Remaining Lives: %d"),Int(health)), fontSize:20))
                    }
                   

                    HStack(spacing: 30) {
                        // quit game button
                        CustomButton(config: CustomButtonConfig(
                            title: appState.localized("Quit Game"),
                            width: 140,
                            buttonColor: .darkBlue,
                            action: {
                                // Directly dismiss the view without showing an alert
                                isMuted.toggle()
                                audioPlayer?.stop()
                                presentationMode.wrappedValue.dismiss()
                            }
                        ))
                        .accessibilityIdentifier("quitGameButton")
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(appState.darkMode ? .darkBlue.opacity(0.9) : Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(radius: 10)
            }.onAppear {
                if !appState.offlineMode {
                    updateBadge(levelNumber: levelNumber)
                }
                saveGameSession(userId: userViewModel.userid, score: score, timePlayed: timePlayed)
            }
        }
    
    func updateBadge(levelNumber: Int) {
        guard let url = URL(string: APIHelper.getBaseURL() + "/badges?userId=\(userId)") else {
            print("Invalid URL for user \(userId)")
            return
        }
        
        let body: [String: Any] = [
            "badge": "level" + String(levelNumber)
        ]
            
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body)
        else {
            print("Failed to encode JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.errorMessage = "Network error, please try again"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("Badge successfully added!")
                        self.errorMessage = nil
                    } else {
                        self.errorMessage =
                        "Error adding badge, please try again"
                    }
                }
            }
        }.resume()
    }
}

//#Preview {
//    EndGameScreenView(levelNumber:1, score:1, health:1, userId: 724, onNextLevel: {
//    },
//    onQuitGame: {
//    })
//}



func saveGameSession(userId: Int, score: Int, timePlayed: TimeInterval) {
    guard let url = URL(string: APIHelper.getBaseURL() + "/stats/userGameSession") else {
        print("Invalid URL")
        return
    }

    let timePlayedMinutes = Int(timePlayed / 60)

    let body: [String: Any] = [
        "userId": String(userId),
        "gameId": "1",
        "score": score,
        "timePlayed": timePlayedMinutes,
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
                    "Failed to save game session. Status code: \(httpResponse.statusCode)"
                )
                return
            }

            print("Game session saved successfully!")
        }
    }.resume()
}
