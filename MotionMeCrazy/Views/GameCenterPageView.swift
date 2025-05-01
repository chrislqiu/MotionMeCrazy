import SwiftUI

struct GameData: Decodable {
    let game_id: Int
    let session_count: Int
}

enum PlayCountType {
    case everyone, me
}

struct GameCenterPageView: View {
    @State private var selectedGame: Int = 0
    @State private var sortOption: SortOption = .default
    @State private var playCountType: PlayCountType = .everyone
    @State private var games: [(gameId: Int, name: String, icon: String, buttonColor: Color, sessionCount: Int, destination: AnyView)] = []
    @State private var showComingSoonPopup: Bool = false
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState

    @State private var showCreateLobbyPopup = false
    @State private var showJoinGamePopup = false
    @State private var nameInput = ""
    @State private var codeInput = ""

    @EnvironmentObject var webSocketManager: WebSocketManager

      init(userViewModel: UserViewModel) {
          self.userViewModel = userViewModel
      }
    enum SortOption {
        case `default`, leastPopular, mostPopular
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image(appState.darkMode ? "background_dm" : "background")
                    .resizable()
                    .ignoresSafeArea()

                VStack {
                    GameCenterHeader(
                        sortOption: $sortOption,
                        playCountType: $playCountType,
                        fetchGameData: fetchGameData,
                        userViewModel: userViewModel
                    )

                    Spacer()

                    GameTabView(
                        selectedGame: $selectedGame,
                        games: games,
                        playCountType: playCountType,
                        userViewModel: userViewModel,
                        webSocketManager: webSocketManager,
                        showJoinGamePopup: $showJoinGamePopup
                    )

                    Spacer()

                    if let responseMessage = webSocketManager.receivedMessage {
                        Text(responseMessage)
                            .font(.headline)
                            .foregroundColor(responseMessage.contains("success") ? .green : .red)
                            .padding()
                    }

                    Spacer()

                    HStack {
                        Spacer()
                        NavigationLink(destination: LeaderboardView(userViewModel: userViewModel)) {
                            HStack(spacing: 6) {
                                Image(systemName: "list.number")
                                    .font(.title2)
                                Text(appState.localized("Leaderboard"))
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.darkBlue)
                            .cornerRadius(10)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }

                .sheet(isPresented: $showCreateLobbyPopup) {
                    CreateLobbyPopup(
                        nameInput: $nameInput,
                        webSocketManager: webSocketManager,
                        userViewModel: userViewModel,
                        showPopup: $showCreateLobbyPopup
                    )
                }

                .sheet(isPresented: $showJoinGamePopup) {
                    JoinGamePopup(
                        codeInput: $codeInput,
                        webSocketManager: webSocketManager,
                        userViewModel: userViewModel,
                        showPopup: $showJoinGamePopup
                    )
                }

                NavigationLink(destination: LobbyView(userViewModel: userViewModel), isActive: $webSocketManager.onJoinLobby) {
                    EmptyView()
                }
            }
        }
        .onAppear {
            games = [
                (gameId: 1, name: "Hole In Wall", icon: "figure.run", buttonColor: .darkBlue, sessionCount: 0, destination: AnyView(HIWGameLobbyView(userViewModel: userViewModel, userId: userViewModel.userid, gameId: 1))),
                (gameId: 2, name: "Game 2", icon: "gamecontroller.fill", buttonColor: .darkBlue, sessionCount: 0, destination: AnyView(Text("Game 2 Coming Soon!")))
            ]
            fetchGameData()
        }
    }

    private func fetchGameData() {
        let playCountQuery: String
        switch playCountType {
        case .everyone:
            playCountQuery = "everyone"
        case .me:
            playCountQuery = "me"
        }

        guard let url = URL(string: APIHelper.getBaseURL() + "/stats/games?playCountType=\(playCountQuery)&userId=\(userViewModel.userid)") else {
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
                    for i in 0..<games.count {
                        if let updatedGame = decodedGames.first(where: { $0.game_id == games[i].gameId }) {
                            games[i].sessionCount = updatedGame.session_count
                        }
                    }
                }
            } catch {
                print("Error decoding game data: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct GameTabView: View {
    @Binding var selectedGame: Int
    let games: [(gameId: Int, name: String, icon: String, buttonColor: Color, sessionCount: Int, destination: AnyView)]
    let playCountType: PlayCountType
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var webSocketManager: WebSocketManager
    @Binding var showJoinGamePopup: Bool

    var body: some View {
        TabView(selection: $selectedGame) {
            ForEach(Array(games.indices), id: \.self) { index in
                NavigationLink(destination: games[index].destination) {
                    VStack {
                        SelectGame(game: games[index], playCountType: playCountType)

                        if games[index].gameId == 1 {
                            HStack(spacing: 5) {
                                Spacer()
                                Button("Create Game") {
                                    webSocketManager.connect()
                                    let message: [String: Any] = [
                                        "type": "CREATE_LOBBY",
                                        "payload": [
                                            "userId": userViewModel.userid,
                                            "username": userViewModel.username
                                        ]
                                    ]
                                    webSocketManager.send(message: message)
                                }
                                .frame(width: 150, height: 50)
                                .background(Color.darkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)

                                Spacer()

                                Button("Join Game") {
                                    showJoinGamePopup = true
                                }
                                .frame(width: 150, height: 50)
                                .background(Color.darkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)

                                Spacer()
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                        }
                    }
                    .scaleEffect(selectedGame == index ? 1.2 : 1.0)
                }
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .frame(height: 375)
    }
}

struct GameCenterHeader: View {
    @Binding var sortOption: GameCenterPageView.SortOption
    @Binding var playCountType: PlayCountType
    let fetchGameData: () -> Void
    let userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink(destination: DailyMissionsView(userId: userViewModel.userid)) {
                    Image(systemName: "checkmark.seal.text.page.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 20)

                Menu {
                    Button(appState.localized("Most Popular")) {
                        sortOption = .mostPopular
                        fetchGameData()
                    }
                    Button(appState.localized("Least Popular")) {
                        sortOption = .leastPopular
                        fetchGameData()
                    }
                    Button(appState.localized("Revert to Default")) {
                        sortOption = .default
                        fetchGameData()
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 20)

                Menu {
                    Button(appState.localized("Personal")) {
                        playCountType = .me
                        fetchGameData()
                    }
                    Button(appState.localized("Everyone")) {
                        playCountType = .everyone
                        fetchGameData()
                    }
                } label: {
                    Image(systemName: "number.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 20)
            }

            CustomHeader(config: .init(title: appState.localized("Game Center")))
                .padding(.top, 10)
        }
    }
}

struct SelectGame: View {
    let game: (gameId: Int, name: String, icon: String, buttonColor: Color, sessionCount: Int, destination: AnyView)
    let playCountType: PlayCountType
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: game.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding()
                .foregroundColor(.white)

            Text(game.name)
                .font(.title)
                .foregroundColor(.white)

            Text(playCountType == .me ? String(format: appState.localized("Your Plays: %d"), game.sessionCount) : String(format: appState.localized("Plays: %d"), game.sessionCount))
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .background(game.buttonColor)
        .cornerRadius(20)
    }
}

struct CreateLobbyPopup: View {
    @Binding var nameInput: String
    @EnvironmentObject var appState: AppState
    @ObservedObject var webSocketManager: WebSocketManager
    @ObservedObject var userViewModel: UserViewModel
    @Binding var showPopup: Bool

    var body: some View {
        VStack {
            Text(appState.localized("Enter your name"))
                .font(.headline)
            TextField(appState.localized("Name"), text: $nameInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(appState.localized("Create")) {
                let message: [String: Any] = [
                    "type": "CREATE_LOBBY",
                    "payload": [
                        "userId": userViewModel.userid,
                        "username": nameInput
                    ]
                ]
                webSocketManager.send(message: message)
                showPopup = false
            }
            .padding()
        }
        .padding()
    }
}

struct JoinGamePopup: View {
    @Binding var codeInput: String
    @EnvironmentObject var appState: AppState
    @ObservedObject var webSocketManager: WebSocketManager
    @ObservedObject var userViewModel: UserViewModel
    @Binding var showPopup: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text(appState.localized("Enter join code"))
                .font(.headline)

            TextField(appState.localized("Code"), text: $codeInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Join") {
                webSocketManager.connect()
                let message: [String: Any] = [
                    "type": "JOIN_LOBBY",
                    "payload": [
                        "userId": userViewModel.userid,
                        "username": userViewModel.username,
                        "code": codeInput
                    ]
                ]
                print("trying to join")
                webSocketManager.lobbyCode = codeInput
                webSocketManager.send(message: message)
                showPopup = false
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .padding()
    }
}
