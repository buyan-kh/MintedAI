import XCTest

final class MintUITests: XCTestCase {
    func testMockedHappyPathShowsResultAndFollowUp() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launch()

        app.buttons["Continue"].tap()
        app.buttons["Continue"].tap()
        app.buttons["Get started"].tap()
        app.buttons["Maybe later"].tap()
        app.buttons["Primary create"].tap()
        app.buttons["Use sample video"].tap()
        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Make the mirror ripple like liquid.")
        app.buttons["Send"].tap()

        XCTAssertTrue(app.staticTexts["Saved to Mint"].waitForExistence(timeout: 10))

        app.textFields["Follow-up prompt"].tap()
        app.textFields["Follow-up prompt"].typeText("Make the arm reflective too.")
        app.buttons["Refine"].tap()

        XCTAssertTrue(app.staticTexts["Make the arm reflective too."].waitForExistence(timeout: 10))
    }
}
