import XCTest

final class StatsPageUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToStatsPage(){
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists, "Start button should exist")
        startButton.tap()
        
        let profileButton = app.buttons["profile"]
        XCTAssertTrue(profileButton.exists, "Profile button should exist")
        profileButton.tap()
        
        let stats = app.buttons["Stats"]
        XCTAssertTrue(stats.exists, "Stats should exist")
        stats.tap()
    }
    
    func testViewGames() {
        navigateToStatsPage()
        
        let highScore = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'High Score:'")).firstMatch
        XCTAssertTrue(highScore.exists, "High score should exist")

        let timePlayed = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Time Played:'")).firstMatch
        XCTAssertTrue(timePlayed.exists, "Time played should exist")
        
        let shareButton = app.buttons["Share"]
        XCTAssertTrue(shareButton.exists, "Share button should exist")

        let clearButton = app.buttons["Clear"]
        XCTAssertTrue(clearButton.exists, "Clear button should exist")
    }
}
