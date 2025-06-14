import Foundation
import SwiftUI

struct LobbyPlayer: Identifiable, Decodable {
    var id: Int { userId }
    let userId: Int
    let username: String
    let score: Int
    let health: Int
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

    func connect() {
        guard let url = URL(string: "ws://192.168.1.29:3000") else {
            print("Invalid WebSocket URL")
            return
        }
        let urlSession = URLSession(configuration: .default)
        webSocketTask = urlSession.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        listenForMessages()
        print("WebSocket connected.")
    }

    func send(message: [String: Any]) {
        guard isConnected else {
            print("Attempted to send, but WebSocket is not connected.")
            return
        }

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
            // Always listen again immediately
            self?.listenForMessages()

            switch result {
            case .failure(let error):
                print("Error receiving WebSocket message: \(error.localizedDescription)")
                self?.isConnected = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.connect() // Simple reconnect logic
                }

            case .success(.string(let message)):
                self?.handleMessage(message)

            case .success(.data(let data)):
                print("Received data: \(data)")

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
                           let code = payload["code"] as? String,
                           let userId = payload["userId"] as? Int,
                           let username = payload["username"] as? String {

                            let players: [LobbyPlayer] = [
                                LobbyPlayer(userId: userId, username: username, score: 0, health: 5)
                            ]

                            DispatchQueue.main.async {
                                self.lobbyPlayers = players
                                self.lobbyCode = code
                                self.isHost = true
                                self.onJoinLobby = true
                                print("Lobby created with code: \(code)")
                            }
                        }

                    case "PLAYER_JOINED", "USER_UPDATED":
                        if let playersArray = jsonResponse["payload"] as? [[String: Any]] {
                            let players: [LobbyPlayer] = playersArray.compactMap { playerDict in
                                guard let userId = playerDict["userId"] as? Int,
                                      let username = playerDict["username"] as? String,
                                      let score = playerDict["score"] as? Int,
                                      let health = playerDict["health"] as? Int else {
                                    return nil
                                }
                                return LobbyPlayer(userId: userId, username: username, score: score, health: health)
                            }

                            DispatchQueue.main.async {
                                self.lobbyPlayers = players
                                self.onJoinLobby = true
                                print("Updated players in lobby.")
                            }
                        }

                    case "GAME_STARTED":
                        DispatchQueue.main.async {
                            self.gameStarted = true
                            print("Game started.")
                        }

                    case "ERROR":
                        if let payload = jsonResponse["payload"] as? String {
                            print("Server error: \(payload)")
                            DispatchQueue.main.async {
                                self.receivedMessage = "Server error: \(payload)"
                            }
                        }

                    default:
                        DispatchQueue.main.async {
                            self.receivedMessage = "Unhandled message type: \(type)"
                            print("Unhandled message type: \(type)")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.receivedMessage = "Invalid JSON structure."
                        print("Invalid JSON structure.")
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
        print("WebSocket disconnected.")
    }
}
