import XCTest

final class FriendsPageUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToFriendsPage() {
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.exists, "Start button should exist")
        
        startButton.tap()
        
        let friendsButton = app.buttons["friends"]
        XCTAssertTrue(friendsButton.exists, "Friends button should exist")
        friendsButton.tap()
    }
    
    func testUserProfileDisplaysCorrectly() {
        navigateToFriendsPage()
        
        let allButton = app.buttons["All"]
        XCTAssertTrue(allButton.exists, "All button should exist")
        
        let pendingButton = app.buttons["Pending"]
        XCTAssertTrue(pendingButton.exists, "Pending button should exist")
        
        let sentButton = app.buttons["Sent"]
        XCTAssertTrue(sentButton.exists, "Sent button should exist")
    }
    
    func testPendingPage() {
        navigateToFriendsPage()
        
        let allButton = app.buttons["All"]
        XCTAssertTrue(allButton.exists, "All button should exist")
        allButton.tap()
        
        let pendingButton = app.buttons["Pending"]
        XCTAssertTrue(pendingButton.exists, "Pending button should exist")
    }
    
    func testNavigateFromPendingToAll() {
        navigateToFriendsPage()
        
        let pendingButton = app.buttons["Pending"]
        XCTAssertTrue(pendingButton.exists, "Pending button should exist")
        pendingButton.tap()
        
        let allButton = app.buttons["All"]
        XCTAssertTrue(allButton.exists, "All button should exist")
        allButton.tap()
        
        let friendsPage = app.staticTexts["Friends"]
        XCTAssertTrue(friendsPage.exists, "Friends page should exist")
    }
}
