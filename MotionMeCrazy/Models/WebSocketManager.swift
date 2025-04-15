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

    init() {}

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

                    if type == "PLAYER_JOINED", let payload = jsonResponse["payload"] as? [[String: Any]] {
                        let players: [LobbyPlayer] = payload.compactMap {
                            guard let userId = $0["userId"] as? Int,
                                  let username = $0["username"] as? String,
                                  let score = $0["score"] as? Int,
                                  let eliminated = $0["eliminated"] as? Bool else {
                                return nil
                            }
                            return LobbyPlayer(userId: userId, username: username, score: score, eliminated: eliminated)
                        }
                        DispatchQueue.main.async {
                            self.lobbyPlayers = players
                            self.isHost = players.first?.userId == 1 // Replace with actual logic
                            self.lobbyCode = "LOBBY567" // Replace with dynamic code
                            self.onJoinLobby = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.receivedMessage = "Unhandled message type or invalid payload."
                        }
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
