import XCTest

final class GameCenterUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToGamePage() {
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists, "Start button should exist")
        
        startButton.tap()
        
        let holeInWallButton = app.buttons["Hole in the Wall"]
        XCTAssertTrue(holeInWallButton.exists, "Hole in the Wall button should exist")
        holeInWallButton.tap()
        
        let playButton = app.buttons["Play"]
        XCTAssertTrue(playButton.exists, "Hole in the Wall button should exist")
        playButton.tap()
    }
    
    func testPauseButton() {
        navigateToGamePage()
        
        let pauseButton = app.buttons["Pause"]
        XCTAssertTrue(pauseButton.exists, "Pause button should exist")
        pauseButton.tap()
        
        let gamePaused = app.staticTexts["Game Paused"]
        XCTAssertTrue(gamePaused.exists, "Game paused screen should be displayed")
        
        let resumeButton = app.buttons["Resume"]
        XCTAssertTrue(resumeButton.exists, "Resume button should exist")
        
        let gameSettings = app.buttons["Game Settings"]
        XCTAssertTrue(gameSettings.exists, "Game settings button should exist")
        
        let quitButton = app.buttons["Quit Game"]
        XCTAssertTrue(quitButton.exists, "Quit button should exist")
        
        resumeButton.tap()
        
        XCTAssertFalse(gamePaused.exists, "Game paused screen should not be displayed")
        
        pauseButton.tap()
        quitButton.tap()
        
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(quitButton.exists)
        yesButton.tap()
        
        sleep(1)
        
        let gameLobby = app.staticTexts["Game Center"]
        XCTAssertTrue(gameLobby.exists, "User should be at lobby")
    }
}
