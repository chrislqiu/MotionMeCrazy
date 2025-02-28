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

        let settingsButton = app.buttons["setting"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
        settingsButton.tap()
    }
    
    func testAudioSliderExists() {
        navigateToSettingsPage()

        let audioSlider = app.sliders.firstMatch
        XCTAssertTrue(audioSlider.exists, "Audio level slider should exist")
        
        audioSlider.adjust(toNormalizedSliderPosition: 0.8)
    }
    
    func testChangeThemeButtonExistsAndTaps() {
        navigateToSettingsPage()

        let themeButton = app.buttons["Change Theme"]
        XCTAssertTrue(themeButton.exists, "Change Theme button should exist")
        themeButton.tap()
    }
    
    func testChangeLanguageButtonExistsAndTaps() {
        navigateToSettingsPage()

        let languageButton = app.buttons["Change Language"]
        XCTAssertTrue(languageButton.exists, "Change Language button should exist")
        languageButton.tap()
    }
}
