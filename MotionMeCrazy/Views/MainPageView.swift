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
    @EnvironmentObject var appState: AppState
    var body: some View {
        //TODO hide tab view when game is active
        TabView {
            GameCenterPageView(userViewModel: userViewModel)
                .tabItem { Image(appState.darkMode ? "home_dm" : "home") }
            ProfilePageView(userViewModel: userViewModel)
                .tabItem { Image(appState.darkMode ? "profile_dm" : "profile") }
            FriendsPageView(userViewModel: userViewModel)
                .tabItem { Image(appState.darkMode ? "friends_dm" : "friends") }
            LeaguePageView(userViewModel: userViewModel)
                .tabItem { Image(appState.darkMode ? "leaderboard_dm" : "leaderboard") }
//            StatisticsPageView(userViewModel: userViewModel)
//                .tabItem {
//                    Image("badge")
//                    Text("Statistics")
//                }
            SettingsPageView(userViewModel: userViewModel)
                .tabItem {
                    Image(appState.darkMode ? "setting_dm" : "setting")
                }

        }
        .id(appState.darkMode)
        .onAppear {
            setTabBarColor()
            // TODO: we need to fetch app setting from database HERE (to show we saved settings from last log in)
            //UITabBar.appearance().backgroundColor = appState.darkMode ? .darkBlue : .white  // Tab background color
            //UITabBar.appearance().barTintColor = appState.darkMode ? .white : .darkBlue  // Tab item color
            //UITabBar.appearance().tintColor = appState.darkMode ? .darkBlue : .white  // color for selected icon
        }
        .onChange(of: appState.darkMode) { _ in
            setTabBarColor()
        }

    }
    
    func setTabBarColor() {
        UITabBar.appearance().backgroundColor = appState.darkMode ? .darkBlue : .white  // Tab background color
        UITabBar.appearance().barTintColor = appState.darkMode ? .white : .darkBlue  // Tab item color
        UITabBar.appearance().tintColor = appState.darkMode ? .darkBlue : .white  // color for selected icon
    }
}

#Preview {
    let testUserViewModel = UserViewModel(userid: 123, username: "TestUser", profilePicId: "profilePicTestId")
    
    NavigationStack {
        MainPageView()
            .environmentObject(testUserViewModel)
    }
}

