import XCTest

final class SettingsPageUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToSettingsPage() {
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists, "Start button should exist")
        startButton.tap()

        let settingsButton = app.buttons["Settings"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
        settingsButton.tap()
    }

    func testSettingsButtonExistsAndTaps() {
        navigateToSettingsPage()

        let settingsTabButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsTabButton.exists, "Settings tab button should exist")
    }

    func testGameSettingsButtonExistsAndTaps() {
        navigateToSettingsPage()

        let gameSettingsButton = app.buttons["gameSettingsButton"]
        XCTAssertTrue(gameSettingsButton.exists, "Game Settings tab button should exist")
        gameSettingsButton.tap()
        
        let gameSettingsScreen = app.staticTexts["gameSettingsScreen"]
        XCTAssertTrue(gameSettingsScreen.exists, "Game Settings screen should be visible after tapping the button")
    }
    
    func testAudioSliderExists() {
        navigateToSettingsPage()

        let audioSlider = app.sliders.firstMatch
        XCTAssertTrue(audioSlider.exists, "Audio level slider should exist")
        
        audioSlider.adjust(toNormalizedSliderPosition: 0.8)
    }
    
    func testChangeThemeButtonExistsAndTaps() {
        navigateToSettingsPage()

        let themeButton = app.buttons["themeButton"]
        XCTAssertTrue(themeButton.exists, "Change Theme button should exist")
        themeButton.tap()
    }
    
    func testChangeLanguageButtonExistsAndTaps() {
        navigateToSettingsPage()

        let languageButton = app.buttons["languageButton"]
        XCTAssertTrue(languageButton.exists, "Change Language button should exist")
        languageButton.tap()
    }
}
