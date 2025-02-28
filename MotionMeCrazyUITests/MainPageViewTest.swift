import XCTest

final class MainPageUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToMainPage() {
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists, "Start button should exist")
        
        startButton.tap()
    }
    
    func testViewGames() {
        navigateToMainPage()
        
        sleep(1)
        
        let holeInWall = app.buttons["Hole in the Wall"]
        XCTAssertTrue(holeInWall.exists, "Hole in the Wall button should exist")
        
        let window = app.windows.firstMatch
        let start = window.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
        let end = window.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5))

        start.press(forDuration: 0.1, thenDragTo: end)
        
        let game2 = app.buttons["Game 2"]
        XCTAssertTrue(game2.exists, "Game 2 button should exist")
    }
    
    func testAllButtonsVisibleAndWork() {
        navigateToMainPage()
        
        sleep(1)

        let homeButton = app.buttons["home"]
        XCTAssertTrue(homeButton.exists, "Home button should exist")
        
        let profileButton = app.buttons["profile"]
        XCTAssertTrue(profileButton.exists, "Profile button should exist")
        profileButton.tap()
        
        let profile = app.staticTexts["Profile"]
        XCTAssertTrue(profile.exists, "Profile should exist")

        let friendsButton = app.buttons["friends"]
        XCTAssertTrue(friendsButton.exists, "Friends button should exist")
        friendsButton.tap()
        
        let friends = app.staticTexts["Friends"]
        XCTAssertTrue(friends.exists, "Friends should exist")

        let leaderboardButton = app.buttons["leaderboard"]
        XCTAssertTrue(leaderboardButton.exists, "Leaderboard button should exist")
        leaderboardButton.tap()
        
        let leagues = app.staticTexts["My Leagues"]
        XCTAssertTrue(leagues.exists, "Leagues should exist")
        homeButton.tap()
        
        let settingsButton = app.buttons["setting"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
        settingsButton.tap()
        
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.exists, "Settings should exist")
    }
}
