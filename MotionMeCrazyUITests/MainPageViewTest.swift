import XCTest

final class MainPageUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func testViewGames() {
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
        
        let moreButton = app.buttons["More"]
        XCTAssertTrue(moreButton.exists, "More button should exist")
        moreButton.tap()
        
        let statsButton = app.staticTexts["Statistics"]
        XCTAssertTrue(statsButton.exists, "Stats button should exist")
        statsButton.tap()
        
        let stats = app.staticTexts["Statistics"]
        XCTAssertTrue(stats.exists, "Stats should exist")
        
        moreButton.firstMatch.tap()
        
        let settingsButton = app.staticTexts["Settings"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
        settingsButton.tap()
        
        let settings = app.staticTexts["Settings"]
        XCTAssertTrue(settings.exists, "Settings should exist")
        
        homeButton.tap()
        
        let home = app.staticTexts["Game Center"]
        XCTAssertTrue(home.exists, "Home should exist")
    }
}
