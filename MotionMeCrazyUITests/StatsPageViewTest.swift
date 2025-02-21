import XCTest

final class StatsPageUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToStatsPage(){
        let moreButton = app.buttons["More"]
        XCTAssertTrue(moreButton.exists, "More button should exist")
        moreButton.tap()
        
        let statsButton = app.staticTexts["Statistics"]
        XCTAssertTrue(statsButton.exists, "Stats button should exist")
        statsButton.tap()
    }
    
    func testViewGames() {
        navigateToStatsPage()
        
        let stats = app.staticTexts["Statistics"]
        XCTAssertTrue(stats.exists, "Stats should exist")
        
        let highScore = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'High Score:'")).firstMatch
        XCTAssertTrue(highScore.exists, "High score should exist")

        let timePlayed = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Time Played:'")).firstMatch
        XCTAssertTrue(timePlayed.exists, "Time played should exist")
    }
}
