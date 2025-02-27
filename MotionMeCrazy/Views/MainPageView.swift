//
//  MainPageView.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto on 2/12/25.
//

import SwiftUI

//for tab bar and main view 
struct MainPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    var body: some View {
        //TODO hide tab view when game is active
        TabView {
            GameCenterPageView()
                .tabItem { Image("home") }
            ProfilePageView(userViewModel: userViewModel)
                .tabItem { Image("profile") }
            FriendsPageView(userViewModel: userViewModel)
                .tabItem { Image("friends") }
            LeaguePageView(userViewModel: userViewModel)
                .tabItem { Image("leaderboard") }
//            StatisticsPageView(userViewModel: userViewModel)
//                .tabItem {
//                    Image("badge")
//                    Text("Statistics")
//                }
            SettingsPageView()
                .tabItem {
                    Image("setting")
                }

        }
        .onAppear {
            UITabBar.appearance().backgroundColor = .white  // Tab background color
            UITabBar.appearance().barTintColor = .darkBlue  // Tab item color
            UITabBar.appearance().tintColor = .white  // color for selected icon
        }

    }
}

#Preview {
    let testUserViewModel = UserViewModel(userid: 123, username: "TestUser", profilePicId: "profilePicTestId")
    
    NavigationStack {
        MainPageView()
            .environmentObject(testUserViewModel)
    }
}

