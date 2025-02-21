import XCTest

final class FriendsPageUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        app.launch()
    }
    
    func navigateToFriendsPage() {
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
        
        let userRow = app.buttons["userRow"]
        XCTAssertTrue(userRow.exists, "User list should exist")
        
        let pendingButton = app.buttons["Pending"]
        XCTAssertTrue(pendingButton.exists, "Pending button should exist")
        pendingButton.tap()

        XCTAssertTrue(userRow.exists, "User list should exist")
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
    
    func testFriendsListPage() {
        navigateToFriendsPage()
        
        let allButton = app.buttons["All"]
        XCTAssertTrue(allButton.exists, "All button should exist")
        allButton.tap()
        
        let userButton = app.buttons["userRow"]
        XCTAssertTrue(userButton.exists, "User button should exist")
        
        let userText = app.staticTexts["userRow"]
        XCTAssertTrue(userText.exists, "User text should exist")
        
        let userPfp = app.images["userRow"]
        XCTAssertTrue(userPfp.exists, "User image should exist")
    }
}
