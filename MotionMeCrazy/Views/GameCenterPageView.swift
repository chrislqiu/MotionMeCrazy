//
//  GameCenterPageView.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto 2/13/25.
//


import SwiftUI

struct GameCenterPageView: View {
    @State private var selectedGame: Int = 0
    @State private var sortOption: SortOption = .default // Enum to track sorting options
    @ObservedObject var userViewModel: UserViewModel
    
    private var games: [(name: String, icon: String, buttonColor: Color, destination: AnyView)] = []
    
    enum SortOption {
        case `default`, leastPopular, mostPopular
    }
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        self.games = [("Hole in the Wall", "figure.run", .darkBlue, AnyView(HIWGameLobbyView(userId: userViewModel.userid, gameId: selectedGame))),
                      ("Game 2", "gamecontroller.fill", .darkBlue, AnyView(Text("Coming Soon!")))]
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemBlue
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemBlue.withAlphaComponent(0.5)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack {
                    // header and sort button
                    VStack {
                        HStack {
                            Spacer()
                            Menu {
                                Button("Most Popular") {
                                    sortOption = .mostPopular
                                    // TODO:  sort the games by most popular
                                }
                                Button("Least Popular") {
                                    sortOption = .leastPopular
                                    // TODO: sort the games by least popular
                                }
                                Button("Revert to Default") {
                                    sortOption = .default
                                    // TODO: go back to default
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 20)
                        }
                        
                        CustomHeader(config: .init(title: "Game Center"))
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                    
                    // game selection
                    TabView(selection: $selectedGame) {
                        ForEach(Array(games.indices), id: \.self) { index in
                            SelectGame(game: games[index])
                                .scaleEffect(selectedGame == index ? 1.2 : 1.0)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 325)
                    
                    Spacer()
                }
            }
        }
    }
}



struct SelectGame: View {
    let game: (name: String, icon: String, buttonColor: Color, destination: AnyView)
    
    var body: some View {
        VStack {
            Image(systemName: game.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(game.buttonColor)
                .padding(.bottom, 10)
            
            CustomButton(config: .init(title: game.name, width: 250, buttonColor: game.buttonColor, destination: game.destination))
        }
        .frame(width: 250, height: 150)
    }
}

#Preview {
    GameCenterPageView(userViewModel: UserViewModel(userid: 421, username: "JazzyLegend633", profilePicId: "pfp2"))
}
