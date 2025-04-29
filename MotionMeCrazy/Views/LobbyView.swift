import SwiftUI

struct LobbyView: View {
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var webSocketManager: WebSocketManager

    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()

                VStack {
                    // Header
                    HStack {
                        Spacer()
                        Text("Game Lobby")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color("DarkBlue"))

                    Spacer()

                    VStack(spacing: 20) {
                        // Lobby Code
                        VStack {
                            Text("Lobby Code")
                                .foregroundColor(.white)
                                .font(.headline)

                            Text(webSocketManager.lobbyCode)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("DarkBlue"))
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }

                        // Player List
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Players in Lobby:")
                                .foregroundColor(.white)
                                .font(.headline)

                            ForEach(webSocketManager.lobbyPlayers, id: \.userId) { player in
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.white)

                                    Text(player.username)
                                        .foregroundColor(.white)
                                        .fontWeight(player.username == userViewModel.username ? .bold : .regular)

                                    Spacer()
                                }
                                .padding()
                                .background(Color("DarkBlue").opacity(0.8))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)

                        // Host-only Start Button
                        if webSocketManager.isHost {
                            Button("Start Game") {
                                startGame()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color("DarkBlue"))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }

                        // Error Message
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }

                        Spacer()
                    }
                    .padding()
                    
                    NavigationLink(destination: AnyView(HIWGameLobbyView(userId: userViewModel.userid, gameId: 1)), isActive: $webSocketManager.gameStarted) {
                        EmptyView()
                    }
                }
            }
        }
    }

    private func startGame() {
        webSocketManager.connect()

        let message: [String: Any] = [
            "type": "START_GAME",
            "payload": [
                "lobbyCode": webSocketManager.lobbyCode,
                "userId": userViewModel.userid
            ]
        ]
        webSocketManager.send(message: message)
    }
}
