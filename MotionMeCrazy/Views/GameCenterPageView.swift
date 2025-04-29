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
    
    @StateObject private var webSocketManager: WebSocketManager

      init(userViewModel: UserViewModel) {
          self.userViewModel = userViewModel
          _webSocketManager = StateObject(wrappedValue: WebSocketManager(userViewModel: userViewModel))
      }
    enum SortOption {
        case `default`, leastPopular, mostPopular
    }

    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()

                VStack {
                    VStack {
                        HStack {
                            Spacer()
                            NavigationLink(destination: DailyMissionsView(userId: userViewModel.userid)) {
                                Image(systemName: "checkmark.seal.text.page.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 20)

                            Menu {
                                Button("Most Popular") {
                                    sortOption = .mostPopular
                                    fetchGameData()
                                }
                                Button("Least Popular") {
                                    sortOption = .leastPopular
                                    fetchGameData()
                                }
                                Button("Revert to Default") {
                                    sortOption = .default
                                    fetchGameData()
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
                                Button("Personal") {
                                    playCountType = .me
                                    fetchGameData()
                                }
                                Button("Everyone") {
                                    playCountType = .everyone
                                    fetchGameData()
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

                    TabView(selection: $selectedGame) {
                        ForEach(Array(games.indices), id: \.self) { index in
                            VStack {
                                SelectGame(game: games[index], playCountType: playCountType)

                                if games[index].gameId == 1 { // Hole In Wall
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
                                        .buttonStyle(DefaultButtonStyle())
                                        .padding()
                                        .frame(width: 150, height: 50, alignment: .center)
                                        .background(Color.darkBlue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white, lineWidth: 2)
                                        )

                                        Spacer()
                                        
                                        Button("Join Game") {
                                            showJoinGamePopup = true
                                        }
                                        .buttonStyle(DefaultButtonStyle())
                                        .padding()
                                        .frame(width: 150, height: 50, alignment: .center)
                                        .background(Color.darkBlue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal, 40)
                                    .padding(.top, 20)
                                    .padding(.bottom, 20)
                                }
                            }
                            .scaleEffect(selectedGame == index ? 1.2 : 1.0)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 375)

                    Spacer()

                    // Show WebSocket response message
                    if let responseMessage = webSocketManager.receivedMessage {
                        Text(responseMessage)
                            .font(.headline)
                            .foregroundColor(responseMessage.contains("success") ? .green : .red)
                            .padding()
                    }
                }

                // Create Lobby Popup
                .sheet(isPresented: $showCreateLobbyPopup) {
                    VStack {
                        Text("Enter Your Name")
                            .font(.title)
                            .padding()

                        TextField("Nickname", text: $nameInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        Button("Create") {
                            webSocketManager.connect()
                            let message: [String: Any] = [
                                "type": "CREATE_LOBBY",
                                "payload": [
                                    "userId": userViewModel.userid,
                                    "username": userViewModel.username
                                ]
                            ]
                            webSocketManager.send(message: message)
                            showCreateLobbyPopup = false
                        }
                        .padding()
                        .background(Color.darkBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()

                        Button("Cancel") {
                            showCreateLobbyPopup = false
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }

                // Join Game Popup
                .sheet(isPresented: $showJoinGamePopup) {
                    VStack {
                        Text("Enter Lobby Code and Your Name")
                            .font(.title)
                            .padding()

                        TextField("Lobby Code", text: $codeInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                   

                        Button("Join") {
                            // Handle join game logic
                            webSocketManager.connect()
                            let message: [String: Any] = [
                                "type": "JOIN_LOBBY",
                                "payload": [
                                    "code": codeInput,
                                    "userId": userViewModel.userid,
                                    "username": userViewModel.userid
                                ]
                            ]
                            webSocketManager.send(message: message)
                            webSocketManager.lobbyCode = codeInput
                            showJoinGamePopup = false
                        }
                        .padding()
                        .background(Color.darkBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()

                        Button("Cancel") {
                            showJoinGamePopup = false
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                
                NavigationLink(destination: LobbyView(userViewModel: userViewModel, webSocketManager: webSocketManager), isActive: $webSocketManager.onJoinLobby) {
                                    EmptyView()
                                }

            }
        }
        .onAppear {
            games = [
                (gameId: 1, name: "Hole In Wall", icon: "figure.run", buttonColor: .darkBlue, sessionCount: 0, destination: AnyView(HIWGameLobbyView(userViewModel: userViewModel, webSocketManager: webSocketManager, userId: userViewModel.userid, gameId: 1))),
                (gameId: 2, name: "Game 2", icon: "gamecontroller.fill", buttonColor: .darkBlue, sessionCount: 0, destination: AnyView(Text("Game 2 Coming Soon!")))
            ]
            fetchGameData()
        }
    }
    
    // Fetch Game Data (for game sessions and play counts)
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

struct SelectGame: View {
    @EnvironmentObject var appState: AppState
    let game: (gameId: Int, name: String, icon: String, buttonColor: Color, sessionCount: Int, destination: AnyView)
    let playCountType: PlayCountType

    var body: some View {
        VStack {
            Image(systemName: game.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(game.buttonColor)
                .padding(.bottom, 10)

            if !appState.offlineMode {
                HStack {
                    Image(systemName: playCountType == .everyone ? "person.3.fill" : "person.fill")
                        .foregroundColor(.darkBlue)
                    Text(playCountText)
                        .font(.headline)
                }
            }

            CustomButton(config: .init(title: game.name, width: 250, buttonColor: game.buttonColor, destination: game.destination))
        }
        .frame(width: 250, height: 150)
    }

    private var playCountText: String {
        switch playCountType {
        case .everyone:
            return "Played \(game.sessionCount) times"
        case .me:
            return "You played this \(game.sessionCount) times"
        }
    }
}

#Preview {
    GameCenterPageView(userViewModel: UserViewModel(userid: 421, username: "JazzyLegend633", profilePicId: "pfp2"))
}
