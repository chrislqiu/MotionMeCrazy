import XCTest

final class LeaguePageUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToLeaguePage(){
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists, "Start button should exist")
        
        startButton.tap()
        
        let leaderboardButton = app.buttons["leaderboard"]
        XCTAssertTrue(leaderboardButton.exists, "Leaderboard button should exist")
        leaderboardButton.tap()
    }
    
    func testLeague() {
        navigateToLeaguePage()
        
        let leagues = app.staticTexts["My Leagues"]
        XCTAssertTrue(leagues.exists, "Leagues should exist")
        
        let createLeague = app.buttons["Create League"]
        XCTAssertTrue(createLeague.exists, "Create League button should exist")
        createLeague.tap()
        
        let createLeagueTitle = app.staticTexts["Create Your League"]
        XCTAssertTrue(createLeagueTitle.exists, "Create League should exist")
        XCTAssertTrue(createLeague.exists, "Create League button should exist")
        
        let createLeagueButtons = app.buttons.matching(identifier: "Create League")
        XCTAssertTrue(createLeagueButtons.firstMatch.exists, "Leagues should exist")
    }
}
