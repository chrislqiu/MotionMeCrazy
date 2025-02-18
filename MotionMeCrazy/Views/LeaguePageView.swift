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

struct LeaguePageView: View {
    @State private var leagues: [String] = [] // TODO: create League object
    @State private var isCreatingLeague: Bool = false
    @State private var leagueName: String = ""
    @State private var leagueMembers: [String] = [""]
    
    // leagues
    private let my_leagues: [String] = ["League 1", "League 2", "League 3"]
    
    var body: some View {
        
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                CustomHeader(config: CustomHeaderConfig(title: "My Leagues"))
                ForEach(my_leagues.indices, id: \.self) { index in
                    CustomText(config: .init(text: my_leagues[index]))
                }
                
                CustomButton(config: .init(title: "Create League", width: 250, buttonColor: .darkBlue) {
                    // action for create league
                    isCreatingLeague.toggle()
                })
                .padding()
                .sheet(isPresented: $isCreatingLeague) {
                    LeaguePopupView(isCreatingLeague: $isCreatingLeague, leagueName: $leagueName, leagueMembers: $leagueMembers)
                }
            }
        }
    }
}

struct LeaguePopupView: View {
    @Binding var isCreatingLeague: Bool
    @Binding var leagueName: String
    @Binding var leagueMembers: [String]

    var body: some View {
        NavigationView {
            VStack {
                CustomText(config: .init(text: "Create Your League"))
                    .font(.headline)
                    .padding()
                TextField("Enter league name", text: $leagueName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                ScrollView {
                    VStack {
                        ForEach(leagueMembers.indices, id: \.self) { index in
                            TextField("Enter username", text: $leagueMembers[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                    }
                }

                HStack {
                    CustomButton(config: .init(title: "Create League", width: 150, buttonColor: .darkBlue, action: {
                        if leagueMembers.count >= 2 {
                            isCreatingLeague = false  // Close popup
                        }
                    }))
                                 
                    CustomButton(config: .init(title: "Add Member", width: 150, buttonColor: .darkBlue) {
                        leagueMembers.append("") // Add new text field
                    })
                    
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Close") { isCreatingLeague = false })
        }
    }
}

struct LeaguePageView_Previews: PreviewProvider {
    static var previews: some View {
        LeaguePageView()
    }
}
