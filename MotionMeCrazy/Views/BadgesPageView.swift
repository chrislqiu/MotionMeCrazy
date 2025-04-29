//
//  BadgesPageView.swift
//  MotionMeCrazy
//
//  Created by Rachel La on 4/1/25.
//

import SwiftUI

struct BadgesPageView: View {
    @ObservedObject var userViewModel: UserViewModel
    @State private var badges: [String] = []
    @State private var errorMessage: String?
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            ZStack {
                Image(appState.darkMode ? "background_dm" :  "background")
                    .resizable()
                    .ignoresSafeArea()
                VStack(alignment: .center, spacing: 10) {
                    CustomHeader(config: CustomHeaderConfig(title: appState.localized("Badges")))
                        .frame(maxWidth: .infinity, alignment: .center)
                    if !appState.offlineMode {
                        LazyVStack(alignment: .center, spacing: 10) {
                            ForEach(0..<badges.count/2 + badges.count % 2, id: \.self) { rowIndex in
                                HStack {
                                    let firstBadgeIndex = rowIndex * 2
                                    let secondBadgeIndex = rowIndex * 2 + 1

                                    if firstBadgeIndex < badges.count,
                                       let _ = UIImage(named: badges[firstBadgeIndex]) {
                                        Image(badges[firstBadgeIndex])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .padding(5)
                                    }

                                    if secondBadgeIndex < badges.count,
                                       let _ = UIImage(named: badges[secondBadgeIndex]) {
                                        Image(badges[secondBadgeIndex])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .padding(5)
                                    }
                                }
                            }
                        }
                    }
                        
                }
                
            }.onAppear {
                if !appState.offlineMode {
                    getBadges()
                }
            }
        }
    }
    
    func getBadges() {
        guard let url = URL(string: APIHelper.getBaseURL() + "/badges?userId=\(userViewModel.userid)") else {
            print("Invalid URL for user \(userViewModel.userid)")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self.errorMessage = "Network error, please try again"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            let badgeResponse = try JSONDecoder().decode(BadgeResponse.self, from: data)
                            print(badgeResponse)
                            self.badges = badgeResponse.badges
                            self.errorMessage = nil
                        } catch {
                            self.errorMessage = "Failed to parse data"
                        }
                    }
                } else {
                    self.errorMessage = "Failed to fetch data"
                }
                print(self.badges)

            }
        }.resume()
    }
}

struct BadgeResponse: Decodable {
    let badges: [String]
}
