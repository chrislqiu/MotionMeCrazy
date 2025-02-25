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
            GameCenterPageView(userViewModel: userViewModel)
                .tabItem { Image("home") }
            ProfilePageView(userViewModel: userViewModel)
                .tabItem { Image("profile") }
            FriendsPageView()
                .tabItem { Image("friends") }
            LeaguePageView()
                .tabItem { Image("leaderboard") }
            StatisticsPageView(user: "test")
                .tabItem {
                    Image("badge")
                    Text("Statistics")
                }
            SettingsPageView()
                .tabItem {
                    Image("setting")
                    Text("Settings")
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
    NavigationStack {
        MainPageView()
                    .environmentObject(UserViewModel())
    }
}
