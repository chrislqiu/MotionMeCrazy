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
    @State private var leagueCodeToJoin: String = "" // Added for league code input
    @State private var isJoiningLeague: Bool = false // Added for tracking league join state
    @State private var inputJoinLeagueCode = ""
    
    @ObservedObject var userViewModel: UserViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack{
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 10) {
                    CustomHeader(config: CustomHeaderConfig(title: "My Leagues"))
                    
                    if !appState.offlineMode {
                        
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
                                        CustomText(config: .init(text: "\(league.name) (Code: \(league.code))"))
                                            .onTapGesture {
                                                joinLeague(leagueCode: league.code) // Handle join league action
                                            }
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
                        
                        CustomButton(config: .init(title: "Join League", width: 250, buttonColor: .darkBlue) {
                            // action for join league
                            isJoiningLeague.toggle()
                        })
                        .padding()
                        .sheet(isPresented: $isJoiningLeague) {
                            Text("Enter League Code")
                                .font(.title)
                                .bold()
                                .padding()
                            
                            TextField("Type here...", text: $inputJoinLeagueCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                                .onChange(of: inputJoinLeagueCode) { newValue in
                                    inputJoinLeagueCode = newValue.uppercased()
                                }
                            
                            
                            HStack {
                                Button("Submit") {
                                    joinLeague(leagueCode: inputJoinLeagueCode)
                                    isJoiningLeague = false
                                }
                                .padding()
                                .background(Color.darkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)

                                Button("Cancel") {
                                    isJoiningLeague = false
                                }
                                .padding()
                                .background(Color.darkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
            
                        }
                        Spacer()
                    } else {
                        Spacer()
                        
                        Text("This page is not available in offline mode")
                            .font(.title2)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding()
                            .accessibilityIdentifier("offlineMessage")
                        
                        Spacer()
                    }
                }
            }
            .onAppear {
                if !appState.offlineMode {
                    fetchLeagues()
                    fetchOtherLeagues()
                }
            }
        }
    }
    
    private func fetchLeagues() {
        guard let url = URL(string: APIHelper.getBaseURL() + "/leagues?userId=\(userViewModel.userid)") else {
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
        guard let url = URL(string: APIHelper.getBaseURL() + "/leagues/not-joined?userId=\(userViewModel.userid)") else {
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
    
    //TODO: UI for joining league with code
    private func joinLeague(leagueCode: String) {
        guard let url = URL(string: APIHelper.getBaseURL() + "/joinLeague") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "leagueCode": leagueCode,
            "userId": userViewModel.userid
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error while joining league: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    fetchLeagues()
                    fetchOtherLeagues()
                }
            } else {
                print("Failed to join league. Status code: \(httpResponse.statusCode)")
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
        guard let url = URL(string: APIHelper.getBaseURL() + "/league") else {
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
