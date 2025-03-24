//
//  GameCenterPageView.swift
//  MotionMeCrazy
//
//  Created by Tea Lazareto 2/13/25.
//


import SwiftUI

struct GameData: Decodable {
    let game_id: Int
    let name: String
    let icon_name: String
    let session_count: Int
}

enum PlayCountType {
    case everyone, me
}

struct GameCenterPageView: View {
    @State private var selectedGame: Int = 0
    @State private var sortOption: SortOption = .default // Enum to track sorting options
    @State private var playCountType: PlayCountType = .everyone // Enum to track play count type
    @State private var games: [(name: String, icon: String, buttonColor: Color, sessionCount: Int, destination: AnyView)] = []
    @State private var showComingSoonPopup: Bool = false
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState
    
    
    enum SortOption {
        case `default`, leastPopular, mostPopular
    }
    
    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
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
                                    fetchGameData(sortType: sortOption, viewType: playCountType)  // 1 for descending order
                                }
                                Button("Least Popular") {
                                    sortOption = .leastPopular
                                    fetchGameData(sortType: sortOption, viewType: playCountType)  // 0 for ascending order
                                }
                                Button("Revert to Default") {
                                    sortOption = .default
                                    fetchGameData(sortType: sortOption, viewType: playCountType)  // Default is most popular
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 20)
                            
                            Menu {
                                Button("Me") {
                                    playCountType = .me
                                    fetchGameData(sortType: sortOption, viewType: playCountType)
                                }
                                Button("Everyone") {
                                    playCountType = .everyone
                                    fetchGameData(sortType: sortOption, viewType: playCountType)
                                }
                            } label: {
                                Image(systemName: "number.circle.fill")
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
        .onAppear {
            if appState.offlineMode {
                games = [
                    (name: "Hole In Wall", icon: "figure.run", buttonColor: .darkBlue, sessionCount: 0, destination: AnyView(HIWGameLobbyView(userId: userViewModel.userid, gameId: 1))),
                    (name: "Game 2", icon: "gamecontroller.fill", buttonColor: .darkBlue, sessionCount: 0, destination: AnyView(Text("Game 2 Coming Soon!")))
                ]
                selectedGame = 0
            } else {
                fetchGameData(sortType: sortOption, viewType: playCountType)
            }
        }
    }
    
    private func fetchGameData(sortType: SortOption, viewType: PlayCountType) {
        let playCountQuery: String
        switch viewType {
        case .everyone:
            playCountQuery = "everyone"
        case .me:
            playCountQuery = "me"
        }
        
        let sortOrder: Int
        switch sortType {
        case .mostPopular:
            sortOrder = 1
        case .leastPopular:
            sortOrder = 0
        case .default:
            sortOrder = 1
        }
        
        guard let url = URL(string: APIHelper.getBaseURL() + "/stats/games?sortType=\(sortOrder)&playCountType=\(playCountQuery)&userId=\(userViewModel.userid)") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching game data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decodedGames: [GameData] = try JSONDecoder().decode([GameData].self, from: data)
                
                DispatchQueue.main.async {
                    games = decodedGames.map { game in
                        let destinationView: AnyView
                        if game.name == "Hole In Wall" {
                            destinationView = AnyView(HIWGameLobbyView(userId: userViewModel.userid, gameId: game.game_id))
                        } else {
                            destinationView = AnyView(Text("Coming Soon!"))
                        }
                        
                        return (name: game.name,
                                icon: game.icon_name,
                                sessionCount: game.session_count,
                                buttonColor: .darkBlue,
                                destination: destinationView)
                    }
                }
                
                
            } catch {
                print("Error decoding game data: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct SelectGame: View {
    @EnvironmentObject var appState: AppState

    let game: (name: String, icon: String, buttonColor: Color, sessionCount: Int, destination: AnyView)
    
    var body: some View {
        VStack {
            Image(systemName: game.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(game.buttonColor)
                .padding(.bottom, 10)
            
            if(!appState.offlineMode){
                Text("Played \(game.sessionCount) times")
                    .font(.headline)
            }
            
            CustomButton(config: .init(title: game.name, width: 250, buttonColor: game.buttonColor, destination: game.destination))
        }
        .frame(width: 250, height: 150)
    }
}


#Preview {
    GameCenterPageView(userViewModel: UserViewModel(userid: 421, username: "JazzyLegend633", profilePicId: "pfp2"))
}
