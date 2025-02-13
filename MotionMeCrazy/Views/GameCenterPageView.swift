//
//  SettingsPageView.swift
//  MotionMeCrazy
//  Tea Lazareto 2/12/2025
//

import SwiftUI
//trying to push
struct GameCenterPageView: View {
    @State private var selectedGame = 0 // current page index
    
    // games
    private let games: [(name: String, icon: String)] = [
        ("Hole in the Wall", "figure.run"),
        ("Game 2", "gamecontroller.fill")
    ]

    init() {
        // this is to customize tge page indicator
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.darkBlue) // shows active dot
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.blue.opacity(0.5)) // inactive dots
    }

    var body: some View {
        
        ZStack {
           
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            
            VStack(spacing: 175) {
                CustomHeader(config: .init(title: "Game Center"))
                
                // Dynamic Game Carousel
                TabView(selection: $selectedGame) {
                    ForEach(games.indices, id: \.self) { index in
                        VStack {
                            Image(systemName: games[index].icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.darkBlue)
                                .padding(.bottom, 10)
                            
                            CustomButton(config: .init(title: games[index].name, width: 250) {
                                // Action for each game
                            })
                        }
                        .frame(width: 250, height: 150)
                        .scaleEffect(selectedGame == index ? 1.2 : 1.0)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 325)
                Spacer()
            }
        }
    }
}

#Preview {
    GameCenterPageView()
        
}
