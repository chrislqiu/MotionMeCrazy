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
    var totalLevels: Int
    var score: Int
    var health: Double
    var userId: Int
    @Binding var isMuted: Bool
    @Binding var audioPlayer: AVAudioPlayer?
    var onNextLevel: () -> Void
    var onQuitGame: () -> Void
    
    // social media stuff
    @State private var showShareScoreSheet = false
    @State private var screenshotScore: UIImage?

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
                        CustomText(config: CustomTextConfig(text: String(format: appState.localized("Remaining Lives: %d"),health), fontSize:20))
                    }
                   

                    HStack(spacing: 30) {
                        // next level button
                        CustomButton(config: CustomButtonConfig(title: appState.localized("Next Level"), width: 140, buttonColor: .darkBlue, action: {
                                onNextLevel() // TODO: add logic for moving onto next level
                            }
                       ))
                        
                        // quit game button
                        CustomButton(config: CustomButtonConfig(title: appState.localized("Quit Game"), width: 140, buttonColor: .darkBlue, action: {
                                //TODO: add logic for going back to home screen
                                //onQuitGame()
                                showQuitConfirmation = true
                            }
                       ))
                        .accessibilityIdentifier("quitGameButton")
                        .alert(appState.localized("Are you sure you want to quit?"), isPresented: $showQuitConfirmation) {
                            Button(appState.localized("No"), role: .cancel) { }
                            Button(appState.localized("Yes"), role: .destructive) {
                                        isMuted.toggle()
                                        audioPlayer?.stop()
                                        presentationMode.wrappedValue.dismiss()
                                        
                                    }
                                }
                    }
                    .padding(.top, 10)
                    
                    // social media
                    CustomButton(config: CustomButtonConfig(title: appState.localized("Share Score"), width: 140, buttonColor: .darkBlue, action: {
                        let image = ShareScoreContent(levelNumber: levelNumber, totalLevels: totalLevels, score: score, health: health).screenshot(size: CGSize(width: 250, height: 300))
                       
                        screenshotScore = image
                       
                        showShareScoreSheet = true
                    }))
                    .sheet(isPresented: $showShareScoreSheet) {
                        if let image = screenshotScore {
                            ShareScoreView(message: "I just scored \(score) points in Motion Me Crazy: Hole in the Wall! Do you think you can beat me?", image: image)
                        } else {
                            CustomText(config: CustomTextConfig(text: "We are still generating your shareable score..please try again later!", fontSize:20))
                        }
                    }
                }
                .padding()
                .background(appState.darkMode ? .darkBlue.opacity(0.9) : Color.white.opacity(0.9))
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

// social media stuff
struct ShareScoreContent: View {
    var levelNumber: Int
    var totalLevels: Int
    var score: Int
    var health: Double
    
    var body: some View {
        
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack(alignment: .center, spacing: 10) {
                Text("Motion Me Crazy")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.darkBlue)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text(String(format: ("Level %d/%d Completed!"), levelNumber, totalLevels))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.darkBlue)
                
                Text(String(format: ("Score: %d"),score))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.darkBlue)
                
                Text(String(format: ("Remaining Lives: %d"), health))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.darkBlue)
            }
            
        }
        .frame(width: 250, height: 300, alignment: .center)
    }
    
}
//
//#Preview {
//    CompletionScreenView(levelNumber:1, score:1, health:1, userId: 724, onNextLevel: {
//    },
//    onQuitGame: {
//    })
//}



