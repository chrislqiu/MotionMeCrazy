import XCTest

final class LeaguePageUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToLeaguePage(){
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

        let addMember = app.buttons["Add Member"]
        XCTAssertTrue(addMember.exists, "Add member button should exist")
        addMember.tap()
        
        let usernameField = app.textFields.matching(NSPredicate(format: "placeholderValue == 'Enter username'")).firstMatch
        XCTAssertTrue(usernameField.exists, "Username text field should exist")
        
        let createLeagueButtons = app.buttons.matching(identifier: "Create League")
        createLeagueButtons.element(boundBy: 1).tap()
        XCTAssertTrue(leagues.exists, "Leagues should exist")
    }
}
