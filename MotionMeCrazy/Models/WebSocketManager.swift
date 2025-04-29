import Foundation
import SwiftUI

struct LobbyPlayer: Identifiable {
    let id = UUID()
    let userId: Int
    let username: String
    let score: Int
    let eliminated: Bool
}

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    @Published var isConnected = false
    @Published var receivedMessage: String? = nil
    @Published var lobbyPlayers: [LobbyPlayer] = []
    @Published var isHost: Bool = false
    @Published var lobbyCode: String = ""
    @Published var onJoinLobby: Bool = false
    @Published var gameStarted: Bool = false
    @ObservedObject var userViewModel: UserViewModel
     
     init(userViewModel: UserViewModel) {
         self.userViewModel = userViewModel
     }

    func connect() {
        guard let url = URL(string: "ws://localhost:3000") else {
            print("Invalid WebSocket URL")
            return
        }
        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        listenForMessages()
    }

    func send(message: [String: Any]) {
        do {
            let messageData = try JSONSerialization.data(withJSONObject: message, options: [])
            let messageString = String(data: messageData, encoding: .utf8) ?? ""
            webSocketTask?.send(.string(messageString)) { error in
                if let error = error {
                    print("Error sending WebSocket message: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error serializing message: \(error.localizedDescription)")
        }
    }

    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error receiving WebSocket message: \(error.localizedDescription)")
            case .success(.string(let message)):
                self?.handleMessage(message)
                self?.listenForMessages() // continue listening
            case .success(.data(let data)):
                print("Received data: \(data)")
                self?.listenForMessages()
            @unknown default:
                break
            }
        }
    }

    private func handleMessage(_ message: String) {
        if let data = message.data(using: .utf8) {
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let type = jsonResponse["type"] as? String {

                    switch type {
                    case "LOBBY_CREATED":
                        if let payload = jsonResponse["payload"] as? [String: Any],
                           let code = payload["code"] as? String {
                            
                            let players: [LobbyPlayer] = [
                                LobbyPlayer(userId: userViewModel.userid, username: userViewModel.username, score: 0, eliminated: false)
                            ]

                            

                            DispatchQueue.main.async {
                                self.lobbyPlayers = players
                                self.lobbyCode = code
                                self.isHost = true
                                self.onJoinLobby = true
                            }
                        }

                    case "PLAYER_JOINED":
                        if let playersArray = jsonResponse["payload"] as? [[String: Any]] {
                            let players: [LobbyPlayer] = playersArray.compactMap { playerDict in
                                guard let userId = playerDict["userId"] as? Int,
                                      let username = playerDict["username"] as? String,
                                      let score = playerDict["score"] as? Int,
                                      let eliminated = playerDict["eliminated"] as? Bool else {
                                    return nil
                                }
                                return LobbyPlayer(userId: userId, username: username, score: score, eliminated: eliminated)
                            }

                            DispatchQueue.main.async {
                                self.lobbyPlayers = players
                                self.onJoinLobby = true
                            }
                        }
                    case "GAME_STARTED":
                        DispatchQueue.main.async {
                                                   self.gameStarted = true
                                               }
                    default:
                        DispatchQueue.main.async {
                            self.receivedMessage = "Unhandled message type: \(type)"
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.receivedMessage = "Invalid JSON structure."
                    }
                }
            } catch {
                print("Error parsing WebSocket response: \(error.localizedDescription)")
            }
        }
    }


    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        isConnected = false
    }
}
