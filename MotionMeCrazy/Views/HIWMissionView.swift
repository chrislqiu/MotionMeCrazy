//
//  HIWMissionView.swift
//  MotionMeCrazy
//
//  Created by Jillian Urgello on 4/1/25.
//

import SwiftUI

struct Mission: Identifiable {
    let id: Int
    let title: String
    var isCompleted: Bool
}

class MissionViewModel: ObservableObject {
    @Published var missions: [Mission] = []
    private let userId: Int

    init(userId: Int) {
        self.userId = userId
        fetchMissions()
    }

    func fetchMissions() {
        let url = URL(string: APIHelper.getBaseURL() + "/missions?userId=\(userId)")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching missions: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {

                let decodedMissions = try JSONDecoder().decode([MissionAPIResponse].self, from: data)

                DispatchQueue.main.async {
                    self.missions = decodedMissions.map { Mission(id: $0.id, title: $0.mission_name, isCompleted: $0.completed) }
                }
            } catch {
                print("Error decoding missions: \(error)")
            }
        }.resume()
    }

    func markAsCompleted(index: Int) {
        let mission = missions[index]
        let url = URL(string: APIHelper.getBaseURL() + "/mission/complete")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "userId": userId,
            "missionId": mission.id
        ]

        do {
            let bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = bodyData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error marking mission as complete: \(error)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        self.missions[index].isCompleted = true
                    }
                } else {
                    print("Failed to mark mission as complete")
                }
            }.resume()
        } catch {
            print("Error encoding request body: \(error)")
        }
    }
}

struct MissionAPIResponse: Decodable {
    let id: Int
    let mission_name: String
    let completed: Bool
}

struct DailyMissionsView: View {
    @StateObject private var viewModel: MissionViewModel
    @Environment(\.presentationMode) var presentationMode

    init(userId: Int) {
        _viewModel = StateObject(wrappedValue: MissionViewModel(userId: userId))
    }

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

            VStack {
                HStack {
                    // X button to dismiss and return to GameCenterPageView

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.darkBlue)
                            .font(.title)
                    }
                    .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {

        }
    }
}

struct DailyMissionsView_Previews: PreviewProvider {
    static var previews: some View {

        DailyMissionsView(userId: 421)
    }
}
