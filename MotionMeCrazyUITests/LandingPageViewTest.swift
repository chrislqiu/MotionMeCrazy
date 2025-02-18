import XCTest

final class LandingPageUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }

    func testUsernameAppears() {
        let usernameField = app.textFields["usernameField"]
        XCTAssertTrue(usernameField.exists)
        XCTAssertFalse(usernameField.value as! String == "", "Username should not be empty")
    }

    func testProfileImageExists() {
        let profileImage = app.images["Selected profile picture"]
        XCTAssertTrue(profileImage.exists, "Profile image should be visible")
    }

    func testProfileImageTapOpensSelector() {
        let profileImage = app.images["Selected profile picture"]
        XCTAssertTrue(profileImage.exists, "Profile image should exist")

        profileImage.tap()

        let profileSelector = app.staticTexts["Profile picture selection screen"]
        XCTAssertTrue(profileSelector.exists, "Profile picture selection should open")
    }

    func testProfilePictureSelection() {
        let profileImage = app.images["Selected profile picture"]
        profileImage.tap()

        let newProfileImage = app.images["pfp2"]
        XCTAssertTrue(newProfileImage.exists, "New profile picture should be available")

        newProfileImage.tap()

        XCTAssertFalse(app.staticTexts["Profile picture selection screen"].exists, "Profile selection modal should close after picking an image")
    }

    func testCopyUsernameButton() {
        let copyButton = app.buttons["Copy"]
        let usernameField = app.textFields["usernameField"]
        
        XCTAssertTrue(copyButton.exists)

        copyButton.tap()

        if let usernameText = usernameField.value as? String {
            XCTAssertEqual(UIPasteboard.general.string, usernameText)
        } else {
            XCTFail("Username field value is not a valid String")
        }
    }


    func testGenerateNewUsername() {
        let usernameField = app.textFields["Username input field"]
        let refreshButton = app.buttons["Generate new username button"]

        XCTAssertTrue(usernameField.exists, "Username field should exist")
        XCTAssertTrue(refreshButton.exists, "Refresh button should exist")

        let initialUsername = usernameField.value as! String

        refreshButton.tap()

        let newUsername = usernameField.value as! String
        XCTAssertNotEqual(initialUsername, newUsername, "Username should change after tapping refresh")
    }

    func testStartButtonExistsAndTap() {
        let startButton = app.buttons["Start button"]
        XCTAssertTrue(startButton.exists, "Start button should exist")

        startButton.tap()

    }
}
