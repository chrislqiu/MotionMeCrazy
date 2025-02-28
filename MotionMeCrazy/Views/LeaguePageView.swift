//
//  LeaguePageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 2/6/25.
//

import SwiftUI

/**
TODO: 1/12
 - saving to DB
 - make pretty
 - create League object
    - consideer what to store in league object and how it will interact
QUESTIONS:
 - what is the league page supposed to contain
 - how does a league work
*/

struct League: Identifiable, Codable {
    let id: Int
    let name: String
    let code: String

    enum CodingKeys: String, CodingKey {
        case id = "league_id"
        case name = "league_name"
        case code = "league_code"
    }
}

struct LeaguePageView: View {
    @State private var myLeagues: [League] = []
    @State private var otherLeagues: [League] = []
    @State private var isCreatingLeague: Bool = false
    @State private var leagueName: String = ""
    
    @ObservedObject var userViewModel: UserViewModel


    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()

            VStack {
                CustomHeader(config: CustomHeaderConfig(title: "My Leagues"))

                if myLeagues.isEmpty {
                    Text("You are not in any leagues")
                        .foregroundColor(.black)
                        .padding()
                } else {
                    ScrollView {
                        VStack {
                            ForEach(myLeagues, id: \.id) { league in
                                CustomText(config: .init(text: "\(league.name) (Code: \(league.code))"))
                            }
                        }
                    }
                }

                CustomHeader(config: CustomHeaderConfig(title: "Other Leagues"))


                if otherLeagues.isEmpty {
                    Text("No other leagues available")
                        .foregroundColor(.black)
                        .padding()
                } else {
                    ScrollView {
                        VStack {
                            ForEach(otherLeagues, id: \.id) { league in
                                CustomText(config: .init(text: "\(league.name)"))
                            }
                        }
                    }
                }

                CustomButton(config: .init(title: "Create League", width: 250, buttonColor: .darkBlue) {
                    // action for create league
                    isCreatingLeague.toggle()
                })
                .padding()
                .sheet(isPresented: $isCreatingLeague) {
                    LeaguePopupView(isCreatingLeague: $isCreatingLeague, leagueName: $leagueName, userId: $userViewModel.userid, onCreateLeague: fetchLeagues)
                }

            }
        }
        .onAppear {
                    fetchLeagues()
                    fetchOtherLeagues()
            }
        
    }

    private func fetchLeagues() {
        guard let url = URL(string: "http://localhost:3000/leagues?userId=\(userViewModel.userid)") else {
            print("Invalid URL or user ID not available")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error while fetching leagues: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                print("Invalid response from server")
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let decodedLeagues = try JSONDecoder().decode([League].self, from: data)
                    DispatchQueue.main.async {
                        myLeagues = decodedLeagues
                    }
                } catch {
                    print("Error decoding leagues: \(error.localizedDescription)")
                }
            } else {
                print("Failed to fetch leagues. Status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }

    private func fetchOtherLeagues() {
        guard let url = URL(string: "http://localhost:3000/leagues/not-joined?userId=\(userViewModel.userid)") else {
            print("Invalid URL or user ID not available")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error while fetching other leagues: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                print("Invalid response from server")
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    let decodedLeagues = try JSONDecoder().decode([League].self, from: data)
                    DispatchQueue.main.async {
                        otherLeagues = decodedLeagues
                    }
                } catch {
                    print("Error decoding other leagues: \(error.localizedDescription)")
                }
            } else {
                print("Failed to fetch other leagues. Status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }

    private func getID(username: String, completion: @escaping (Int?) -> Void) {
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
                            completion(userId)
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

struct LeaguePopupView: View {
    @Binding var isCreatingLeague: Bool
    @Binding var leagueName: String
    @Binding var userId: Int
    var onCreateLeague: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                CustomText(config: .init(text: "Create Your League"))
                    .font(.headline)
                    .padding()

                TextField("Enter league name", text: $leagueName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                HStack {
                    CustomButton(config: .init(title: "Create", width: 150, buttonColor: .darkBlue) {
                        createLeague()
                    })

                    CustomButton(config: .init(title: "Cancel", width: 150, buttonColor: .gray) {
                        isCreatingLeague = false
                    })
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Close") { isCreatingLeague = false })
        }
    }

    private func createLeague() {
        guard let url = URL(string: "http://localhost:3000/league") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "leagueName": leagueName,
            "userId": userId
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error while creating league: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }

            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.isCreatingLeague = false
                    onCreateLeague()
                }
            } else {
                print("Failed to create league. Status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}
