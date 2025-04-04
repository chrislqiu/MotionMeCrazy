import SwiftUI
import AVFoundation
//
//  CompletionScreenView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 3/4/25.
//

struct CompletionScreenView: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState

    @State private var showQuitConfirmation = false // shows quit
    @State private var errorMessage: String?
    var levelNumber: Int
    var score: Int
    var health: Double
    var userId: Int
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
                    CustomText(config: CustomTextConfig(text: "Level \(levelNumber) Completed!", titleColor: .darkBlue, fontSize: 30))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 10) {
                        CustomText(config: CustomTextConfig(text: "Score: \(score)", titleColor: .white, fontSize:20))
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        CustomText(config: CustomTextConfig(text: "Remaining Lives: \(Int(health))", titleColor: .white, fontSize:20))
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.darkBlue.opacity(0.8))
                    .cornerRadius(15)

                    HStack(spacing: 30) {
                        // next level button
                        CustomButton(config: CustomButtonConfig(title: "Next Level", width: 140, buttonColor: .darkBlue, action: {
                                onNextLevel() // TODO: add logic for moving onto next level
                            }
                       ))
                        
                        // quit game button
                        CustomButton(config: CustomButtonConfig(title: "Quit Game", width: 140, buttonColor: .darkBlue, action: {
                                //TODO: add logic for going back to home screen
                                //onQuitGame()
                                showQuitConfirmation = true
                            }
                       ))
                        .accessibilityIdentifier("quitGameButton")
                        .alert("Are you sure you want to quit?", isPresented: $showQuitConfirmation) {
                                    Button("No", role: .cancel) { }
                                    Button("Yes", role: .destructive) {
                                        isMuted.toggle()
                                        audioPlayer?.stop()
                                        presentationMode.wrappedValue.dismiss()
                                        
                                    }
                                }
                    }
                    .padding(.top, 10)
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
                .shadow(radius: 10)
            }.onAppear {
                if !appState.offlineMode {
                    updateBadge(levelNumber: levelNumber)
                }
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
//
//#Preview {
//    CompletionScreenView(levelNumber:1, score:1, health:1, userId: 724, onNextLevel: {
//    },
//    onQuitGame: {
//    })
//}



