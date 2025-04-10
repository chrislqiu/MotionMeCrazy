//
//  Leaderboard.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto on 4/9/25.
//
//
import SwiftUI

struct LeaderboardView: View {
    @State private var publicLeaderboardVisible = true  // track which leaderboard
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode  // access the presentation mode
    
    let leaderboardEntries: [(name: String, score: Int)] = [
        ("FierceOtter123", 120),
        ("ValiantCreature350", 95),
        ("User456", 88),
    ]
    
    let friendsLeaderboardEntries: [(name: String, score: Int)] = [
        ("FriendOne", 150),
        ("FriendTwo", 130),
        ("FriendThree", 110),
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    Text("Leaderboard")
                        .font(.largeTitle)
                        .foregroundColor(.darkBlue)
                        .padding()

                    HStack {
                        Button(action: {
                            withAnimation {
                                publicLeaderboardVisible = true
                            }
                        }) {
                            Text("Public")
                                .font(.headline)
                                .padding()
                                .background(publicLeaderboardVisible ? Color.darkBlue : Color.clear)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            withAnimation {
                                publicLeaderboardVisible = false
                            }
                        }) {
                            Text("Friends")
                                .font(.headline)
                                .padding()
                                .background(publicLeaderboardVisible ? Color.clear : Color.darkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()

                    ZStack {
                        if publicLeaderboardVisible {
                            VStack {
                                Text("Public Leaderboard")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()

                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(leaderboardEntries, id: \.name) { entry in
                                            HStack {
                                                //TODO: ADD REAL USER DATA HEREE
                                                Image("pfp3") /
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(.darkBlue, lineWidth: 3))

                                                VStack(alignment: .leading) {
                                                    Text(entry.name)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                    Text("Score: \(entry.score)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }

                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color("DarkBlue").opacity(0.8))
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .transition(.move(edge: .leading))
                        } else {
                            VStack {
                                Text("Friends Leaderboard")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding()

                                ScrollView {
                                    VStack(spacing: 10) {
                                        ForEach(friendsLeaderboardEntries, id: \.name) { entry in
                                            HStack {
                                                //TODO: ADD REAL USER DATA HEREE
                                                Image("pfp1")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                                    .overlay(Circle().stroke(.darkBlue, lineWidth: 3))

                                                VStack(alignment: .leading) {
                                                    Text(entry.name)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                    Text("Score: \(entry.score)")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }

                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color("DarkBlue").opacity(0.8))
                                            .cornerRadius(10)
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .transition(.move(edge: .trailing))
                        }
                    }
                    .animation(.easeInOut, value: publicLeaderboardVisible)
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                // bye
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundColor(.darkBlue)
                    .padding(.bottom, 40)
            })
        }
    }
}
