//
//  StatisticsPageView.swift
//  MotionMeCrazy
//
//  Created by Chris Qiu on 2/8/25.
//

import SwiftUI

struct StatisticsPageView: View {
    @State private var highScore: Int = 0
    @State private var timePlayed: String = "0h 0m"
    @State private var errorMessage: String?
    let user: String
    var body: some View {
        ZStack {
            // Background
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack {
                // Navigation Bar
                HStack {

                    Spacer()  // Pushes the title to the center

                    // Page Title
                    Text("Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Spacer()  // Ensures the title is centered
                }
                .padding()
                .background(Color("DarkBlue"))

                Spacer()

                // Actual stats
                VStack {
                    Text("High Score: \(highScore)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))
                        .padding(.bottom, 10)
                    Text("Time Played: \(timePlayed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("DarkBlue"))

                    HStack {
                        Spacer()
                        CustomButton(
                            config: CustomButtonConfig(
                                title: "Share",
                                width: 100,
                                buttonColor: .darkBlue,
                                action: {
                                    //TODO: add share func
                                }
                            )
                        )

                        CustomButton(
                            config: CustomButtonConfig(
                                title: "Clear",
                                width: 100,
                                buttonColor: .darkBlue,
                                action: {
                                    getID(username: user) { userId in
                                        if let id = userId {
                                            clearStats(userId: id)
                                        } else {
                                            print("Failed to retrieve User ID")
                                        }
                                    }
                                }
                            )
                        )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                    Spacer()
                }
                .padding(.top, 20)

                Spacer()
            }
        }
    }
    func clearStats(userId: Int) {
        guard let url = URL(string: "http://localhost:3000/stats/userGameSessions?userId=\(userId)")
        else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("User Stats Deleted!")
                        self.errorMessage = nil
                    } else {
                        self.errorMessage = "Failed to delete stats. Status code: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }

    func getID(username: String, completion: @escaping (Int?) -> Void) {
        guard
            let url = URL(
                string: "http://localhost:3000/userId?username=\(username)")
        else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    completion(nil)
                    return
                }

                if httpResponse.statusCode == 200, let data = data {
                    do {
                        let json =
                            try JSONSerialization.jsonObject(
                                with: data, options: []) as? [String: Any]
                        if let userId = json?["userId"] as? Int {
                            completion(userId)  // Return userId
                        } else {
                            print("Invalid response format")
                            completion(nil)
                        }
                    } catch {
                        print(
                            "Failed to decode JSON: \(error.localizedDescription)"
                        )
                        completion(nil)
                    }
                } else {
                    print(
                        "Username not found (status: \(httpResponse.statusCode))"
                    )
                    completion(nil)
                }
            }
        }.resume()
    }
}

#Preview {
    StatisticsPageView(user: "test")
}
