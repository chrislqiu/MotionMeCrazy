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
                        Button(action: {
                            print("Share button tapped")
                        }) {
                            Text("Share")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(Color("DarkBlue"))
                                .cornerRadius(8)
                        }

                        Button(action: {
                            print("Clear button tapped")
                        }) {
                            Text("Clear")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(Color("DarkBlue"))
                                .cornerRadius(8)
                        }
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
}

#Preview {
    StatisticsPageView()
}
