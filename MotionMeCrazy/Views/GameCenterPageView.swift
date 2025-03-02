import SwiftUI

struct GameCenterPageView: View {
    @State private var selectedGame = 0
    
    private let games: [(name: String, icon: String, buttonColor: Color, destination: AnyView)] = [
        ("Hole in the Wall", "figure.run", .darkBlue, AnyView(HIWGameLobbyView())),
        ("Game 2", "gamecontroller.fill", .darkBlue, AnyView(Text("Coming Soon!")))
    ]
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.systemBlue
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.systemBlue.withAlphaComponent(0.5)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("background")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 175) {
                    CustomHeader(config: .init(title: "Game Center"))
                    
                    TabView(selection: $selectedGame) {
                        ForEach(Array(games.indices), id: \..self) { index in
                            SelectGame(game: games[index])
                                .scaleEffect(selectedGame == index ? 1.2 : 1.0)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 325)
                    
                    Spacer()
                }
            }
        }
    }
}

struct SelectGame: View {
    let game: (name: String, icon: String, buttonColor: Color, destination: AnyView)
    
    var body: some View {
        VStack {
            Image(systemName: game.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(game.buttonColor)
                .padding(.bottom, 10)
            
            CustomButton(config: .init(title: game.name, width: 250, buttonColor: game.buttonColor, destination: game.destination))
        }
        .frame(width: 250, height: 150)
    }
}

#Preview {
    GameCenterPageView()
}
