//
//  LandingPageView.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 2/6/25.
//

import SwiftUI

struct LandingPageView: View {
    @State private var selectedImage: String = "pfp1"  // Initial profile image
    @State private var showSelector = false  // Controls modal visibility
    @State private var showCopiedMessage = false
    @State private var username: String = ""

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
    let images = ["pfp1", "pfp2"]

    var body: some View {
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

                // Profile Image Display (Now Opens Selector When Tapped)
                Image(selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .onTapGesture {
                        showSelector.toggle()  // Open selector when tapped
                    }

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

                    // Refresh Button
                    Button(action: {
                        username = generateRandomUsername()
                    }) {
                        Image(systemName: "arrow.clockwise")  // Refresh icon
                            .font(.title2.bold())
                            .foregroundColor(.black)
                    }
                }.padding(.top, 10)

                // Show confirmation message
                if showCopiedMessage {
                    Text("Copied to clipboard!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.top, 5)
                }
                Button(action: {
                    print("Start button tapped!")  // Replace with actual action
                }) {
                    Text("Start")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 180, height: 50)
                        .background(Color.blue)
                        .cornerRadius(25)
                        .shadow(radius: 5)
                }.padding(.top, 20)
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
                    }
                }
                Spacer()
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
}

#Preview {
    LandingPageView()
}
