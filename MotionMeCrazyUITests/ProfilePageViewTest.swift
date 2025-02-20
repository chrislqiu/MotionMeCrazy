import XCTest

final class ProfilePageUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToProfilePage() {
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists, "Start button should exist")
        startButton.tap()

        let profileButton = app.buttons["profile"]
        XCTAssertTrue(profileButton.exists, "Profile button should exist")
        profileButton.tap()
    }
    
    func testUserProfileDisplaysCorrectly() {
        navigateToProfilePage()
        
        let usernameLabel = app.staticTexts["username"]
        XCTAssertTrue(usernameLabel.exists, "Username should be displayed")
        
        let userIdLabel = app.staticTexts["userid"]
        XCTAssertTrue(userIdLabel.exists, "User ID should be displayed")
        
        let profileImage = app.images["profilePicture"]
        XCTAssertTrue(profileImage.exists, "Profile picture should be displayed")
    }
    
    func testModifyUsername() {
        navigateToProfilePage()
        
        let editButton = app.buttons["Edit"]
        XCTAssertTrue(editButton.exists, "Edit button should exist")
        editButton.tap()
        
        let alert = app.alerts["Edit Username"]
        XCTAssertTrue(alert.exists, "Edit username alert should appear")
        
        let textField = alert.textFields.firstMatch
        XCTAssertTrue(textField.exists, "Username input field should exist")
        textField.tap()
        textField.typeText("NewUsername")
        
        let submitButton = alert.buttons["Submit"]
        XCTAssertTrue(submitButton.exists, "Submit button should exist")
        submitButton.tap()
        
        let updatedUsernameLabel = app.staticTexts["NewUsername"]
        XCTAssertTrue(updatedUsernameLabel.exists, "Updated username should be displayed")
    }
    
    func testModifyProfilePicture() {
        navigateToProfilePage()
        
        let profileImage = app.images["profilePicture"]
        XCTAssertTrue(profileImage.exists, "Profile picture should exist")
        profileImage.tap()
        
        let imageSelector = app.staticTexts["Select Your Profile Picture"]
        XCTAssertTrue(imageSelector.exists, "Profile picture selector should appear")
        
        let newProfileImage = app.images["pfp2"]
        XCTAssertTrue(newProfileImage.exists, "New profile picture option should exist")
        newProfileImage.tap()
        
        XCTAssertEqual(profileImage.label, "pfp2", "Profile picture should be updated")
    }
}
