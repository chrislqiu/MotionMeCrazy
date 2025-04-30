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

    var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    @State private var selectedTabIndex: Int = 0

    var body: some View {
        let content: AnyView = {
            if isIpad {
                return AnyView(
                    VStack {
                        VStack {
                            switch selectedTabIndex {
                            case 0: GameCenterPageView(userViewModel: userViewModel)
                            case 1: ProfilePageView(userViewModel: userViewModel)
                            case 2: FriendsPageView(userViewModel: userViewModel)
                            case 3: LeaguePageView(userViewModel: userViewModel)
                            case 4: SettingsPageView(userViewModel: userViewModel)
                            default: EmptyView()
                            }
                        }

                        Spacer()

                        HStack {
                            Spacer()
                            tabButton(index: 0, imageName: "home")
                            Spacer()
                            tabButton(index: 1, imageName: "profile")
                            Spacer()
                            tabButton(index: 2, imageName: "friends")
                            Spacer()
                            tabButton(index: 3, imageName: "leaderboard")
                            Spacer()
                            tabButton(index: 4, imageName: "setting")
                            Spacer()
                        }
                        .frame(height: UIScreen.main.bounds.height * 0.1)
                        .background(appState.darkMode ? Color.black : Color.white)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    .id(appState.darkMode)
                )
            } else {
                return AnyView(
                    TabView {
                        GameCenterPageView(userViewModel: userViewModel)
                            .tabItem { Image(appState.darkMode ? "home_dm" : "home") }

                        ProfilePageView(userViewModel: userViewModel)
                            .tabItem { Image(appState.darkMode ? "profile_dm" : "profile") }

                        FriendsPageView(userViewModel: userViewModel)
                            .tabItem { Image(appState.darkMode ? "friends_dm" : "friends") }

                        LeaguePageView(userViewModel: userViewModel)
                            .tabItem { Image(appState.darkMode ? "leaderboard_dm" : "leaderboard") }

                        SettingsPageView(userViewModel: userViewModel)
                            .tabItem { Image(appState.darkMode ? "setting_dm" : "setting") }
                    }
                    .id(appState.darkMode)
                )
            }
        }()

        return content
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

    func tabButton(index: Int, imageName: String) -> some View {
        Button(action: {
            selectedTabIndex = index
        }) {
            Image(appState.darkMode ? "\(imageName)_dm" : imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
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
    let testAppState = AppState()

    NavigationStack {
        MainPageView()
            .environmentObject(testUserViewModel)
            .environmentObject(testAppState)
    }
}
