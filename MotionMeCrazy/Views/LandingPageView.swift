//
//  LandingPageView.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 2/6/25.
//

import SwiftUI

struct LandingPageView: View {
    @StateObject private var userViewModel = UserViewModel(userid: 0, username: "", profilePicId: "")
    
    @State private var selectedImage: String = "pfp1"  // Initial profile image
    @State private var showSelector = false  // Controls modal visibility
    @State private var showCopiedMessage = false
    @State private var username: String = ""
    @State private var errorMessage: String?  // For displaying errors
    @State private var navigateToMainPage = false

    let adjectives = [
        "Swift", "Crazy", "Fast", "Brave", "Happy", "Funky", "Epic", "Chill",
        "Mighty", "Wild",
        "Zany", "Jolly", "Clever", "Hyper", "Radical", "Witty", "Snazzy",
        "Perky", "Bold",
        "Spunky", "Cheery", "Peppy", "Snappy", "Zesty", "Quirky", "Jumpy",
        "Jazzy", "Nifty", "Zippy", "Speedy", "Daring", "Bouncy", "Peppy",
        "Lively", "Snuggly",
        "Sporty", "Chirpy", "Sassy", "Perky", "Rowdy", "Playful", "Bubbly",
        "Jumpy",
        "Giddy", "Sunny", "Zippy", "Twisty", "Hasty", "Breezy", "Dandy",
        "Wacky",
        "Goofy", "Zesty",
    ]
    let nouns = [
        "Coder", "Runner", "Gamer", "Explorer", "Ninja", "Pioneer", "Warrior",
        "Champion", "Wizard", "Legend",
        "Jester", "Rebel", "Rogue", "Hero", "Voyager", "Nomad", "Seeker",
        "Racer", "Sprinter", "Inventor",
        "Tinkerer", "Hacker", "Pilot", "Rider", "Samurai", "Gladiator",
        "Guardian", "Smasher", "Drifter", "Ranger",
        "Adventurer", "Scholar", "Artist", "Dreamer", "Wanderer", "Builder",
        "Sculptor", "Creator", "Visionary", "Captain",
        "Magician", "Specter", "Phantom", "Alchemist", "Sniper", "Hunter",
        "Beast", "Viking", "Knight", "Titan",
    ]
    let images = ["pfp1", "pfp2", "pfp3", "pfp4", "pfp5", "pfp6"]

    var body: some View {
        NavigationView {
            //Forces the background to be in the very back
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                //Vertically stack the text
                VStack {
                    Text("Motion Me\nCrazy")
                        .font(.system(size: 48, weight: .heavy))
                        .foregroundColor(Color("DarkBlue"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 35)
                        .accessibilityIdentifier("appTitle")
                    
                    // Profile Image Display (Now Opens Selector When Tapped)
                    Image(selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.darkBlue, lineWidth: 3))
                        .onTapGesture {
                            showSelector.toggle()  // Open selector when tapped
                        }
                        .accessibilityIdentifier("profilePicture")
                    
                    HStack {
                        TextField("Enter your username", text: $username)
                            .font(.title2)
                            .padding()
                            .frame(width: 250)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10).stroke(
                                    Color.gray, lineWidth: 1)
                            )
                            .multilineTextAlignment(.center)
                            .onAppear {
                                username = generateRandomUsername()
                            }
                            .accessibilityLabel("usernameField")
                        
                        // Copy to Clipboard Button
                        Button(action: {
                            UIPasteboard.general.string = username
                            showCopiedMessage = true
                            
                            // Hide message after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopiedMessage = false
                            }
                        }) {
                            Image(systemName: "doc.on.doc")  // Clipboard icon
                                .font(.title)
                                .foregroundColor(.black)
                        }
                        .padding(.leading, 5)
                        .accessibilityIdentifier("copyButton")
                        
                        // Refresh Button
                        Button(action: {
                            username = generateRandomUsername()
                        }) {
                            Image(systemName: "arrow.clockwise")  // Refresh icon
                                .font(.title2.bold())
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 10)
                    .accessibilityIdentifier("generateUsernameButton")
                    
                    // Show confirmation message
                    if showCopiedMessage {
                        Text("Copied to clipboard!")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.top, 5)
                            .accessibilityIdentifier("copyMessage")
                    }
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.top, 5)
                            .accessibilityIdentifier("errorMessage")
                    }
                    
                    NavigationLink(
                        destination: MainPageView()
                            .environmentObject(userViewModel)
                            .navigationBarBackButtonHidden(true),
                        isActive: $navigateToMainPage
                    ) {
                        Button(action: {
                            createUser()
                            navigateToMainPage = true
                        }) {
                            Text("Start")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 180, height: 50)
                                .background(Color.blue)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                        .padding(.top, 20)
                        .accessibilityIdentifier("startButton")
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $showSelector) {
                VStack {
                    Text("Select Your Profile Picture")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))
                        .padding(.top, 20)
                        .accessibilityIdentifier("picSelectScreen")
                    
                    LazyVGrid(
                        columns: Array(repeating: .init(.flexible()), count: 3),
                        spacing: 15
                    ) {
                        ForEach(images, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(
                                            selectedImage == imageName
                                            ? Color.blue : Color.clear,
                                            lineWidth: 4)
                                )
                                .onTapGesture {
                                    selectedImage = imageName
                                    showSelector = false  // Close modal after selection
                                }
                                .accessibilityIdentifier("picOption")
                            
                        }
                    }
                    Spacer()
                }
                
            }
            
        }
    }

    //Generates random username
    func generateRandomUsername() -> String {

        let randomAdj = adjectives.randomElement() ?? "Cool"
        let randomNoun = nouns.randomElement() ?? "User"
        let randomNum = Int.random(in: 100...999)

        return "\(randomAdj)\(randomNoun)\(randomNum)"
    }
    
    func createUser() {
        guard let url = URL(string: "http://localhost:3000/user") else {
            print("Invalid URL")
            return
        }

        let body: [String: Any] = [
            "username": username,
            "profilePicId": selectedImage,
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
                if error != nil {
                    self.errorMessage = "Network error, please try again"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let data = data {
                            do {
                                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                                userViewModel.userid = userResponse.userid
                                userViewModel.username = userResponse.username
                                userViewModel.profilePicId = userResponse.profilepicid
                                self.errorMessage = nil
                            } catch {
                                self.errorMessage = "Failed to parse response"
                                print(error)
                            }
                        }
                        print("User successfully created!")
                        self.errorMessage = nil
                    } else {
                        self.errorMessage =
                            "Username already exists, please try again"
                    }
                }
            }
        }.resume()
    }
}

struct UserResponse: Codable {
    let userid: Int
    let username: String
    let profilepicid: String
}

#Preview {
    LandingPageView()
}
