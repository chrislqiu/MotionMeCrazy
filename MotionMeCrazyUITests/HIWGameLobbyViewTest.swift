import XCTest

final class HIWGameLobbyUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToGamePage() {
        let holeInWallButton = app.buttons["Hole in the Wall"]
        XCTAssertTrue(holeInWallButton.exists, "Hole in the Wall button should exist")
        holeInWallButton.tap()
    }
    
    func testModeButtonOpensSelection() {
        navigateToGamePage()
        
        let modeButton = app.buttons["modeButton"]
        XCTAssertTrue(modeButton.exists, "Mode button should exist")
        modeButton.tap()
        
        let modeSelectionTitle = app.staticTexts["modeSelectionTitle"]
        XCTAssertTrue(modeSelectionTitle.exists, "Mode selection sheet should be displayed")
    }
    
    func testDefaultModeIsNormal() {
        navigateToGamePage()
        
        let modeButton = app.buttons["modeButton"]
        XCTAssertTrue(modeButton.exists, "Mode button should exist")
        modeButton.tap()
        
        let defaultDifficultyText = app.buttons["Difficulty, Normal"]
        XCTAssertTrue(defaultDifficultyText.exists, "The default difficulty should be 'Normal'")
        
        defaultDifficultyText.tap()
        
        let easyButton = app.buttons["Easy"]
        let normalButton = app.buttons["Normal"]
        let hardButton = app.buttons["Hard"]
        
        XCTAssertTrue(easyButton.exists)
        XCTAssertTrue(normalButton.exists)
        XCTAssertTrue(hardButton.exists)
    }
    
    func testCanDismissModeSelectionWithoutChoosing() {
        navigateToGamePage()
        
        let modeButton = app.buttons["modeButton"]
        modeButton.tap()
        
        let cancelButton = app.buttons["Close"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist")
        cancelButton.tap()
        
        XCTAssertFalse(cancelButton.exists, "Mode selection should close when cancel is tapped")
    }
    
    func testQuitButton(){
        navigateToGamePage()
        
        let quitButton = app.buttons["exitButton"]
        XCTAssertTrue(quitButton.exists, "Quit button should exist")
        
        quitButton.tap()
        
        let holeInWallButton = app.buttons["Hole in the Wall"]
        XCTAssertTrue(holeInWallButton.exists, "Hole in the Wall button should exist")
    }
}
