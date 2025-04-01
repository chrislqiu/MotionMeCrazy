//
//  HIWMissionView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 4/1/25.
//

import SwiftUI

struct Mission: Identifiable {
    let id = UUID()
    let title: String
    var isCompleted: Bool
}

class MissionViewModel: ObservableObject {
    @Published var missions: [Mission] = []
    private let allMissions: [String] = [
        "Play 3 levels", "Dodge 10 obstacles", "Earn 500 points", "Survive for 2 minutes",
        "Complete a level without taking damage", "Play 5 levels", "Earn a total of 1000 points",
        "Complete a level without taking damage in medium mode", "Complete a level without taking damage in easy mode",
        "Complete a level without taking damage in hard mode", "Reach a combo streak of 5", "Break through 3 walls",
        "Finish a level in under 30 seconds", "Jump through 10 holes",
        "Customize your character", "Earn 500 points in hard mode", "Score 200 points in one level",
        "Try a different difficulty mode", "Play 10 minutes in one session", "Earn a perfect score in a level",
        "Earn 500 points in medium mode", "Try a new challenge mode", "Dodge 20 obstacles in a row", "Hit a score milestone",
        "Play with a friend", "Complete 2 levels without failing", "Reach a leaderboard position",
        "Achieve a new personal best", "Complete a mission streak for 3 days", "Win a daily reward"
    ]
    
    init() {
        resetMissions()
    }
    
    func resetMissions() {
            let selectedMissions = allMissions.shuffled().prefix(3).map { Mission(title: $0, isCompleted: false) }
            missions = selectedMissions
    }
    
    func markAsCompleted(index: Int) {
            missions[index].isCompleted = true
    }
}

struct DailyMissionsView: View {
    @StateObject private var viewModel = MissionViewModel()
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                
                CustomHeader(config: CustomHeaderConfig(title: "Daily Missions"))
                
                List {
                    ForEach(viewModel.missions.indices, id: \.self) { index in
                        HStack {
                            CustomText(config: CustomTextConfig(text: viewModel.missions[index].title, titleColor: .darkBlue, fontSize: 18))
                            Spacer()
                            if viewModel.missions[index].isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.darkBlue)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .onTapGesture {
                            viewModel.markAsCompleted(index: index)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .onAppear {
                // simulate daily reset (actual implentation completed in backend)
                // right now it just displays 3 random missions every 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    viewModel.resetMissions()
                }
                
            }
        }
    }
}

struct DailyMissionsView_Previews: PreviewProvider {
    static var previews: some View {
        DailyMissionsView()
    }
}

