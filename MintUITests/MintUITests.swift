import XCTest

@MainActor
final class MintUITests: XCTestCase {
    func testGeneratePathMatchesHTMLFlow() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launch()

        completeOnboarding(app)
        app.buttons["Generate mode"].tap()
        app.buttons["Primary create"].tap()

        XCTAssertTrue(app.staticTexts["What do you want to see?"].waitForExistence(timeout: 5))

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Cinematic sunset over a futuristic city skyline, drone shot")
        app.buttons["Generate"].tap()

        XCTAssertTrue(app.staticTexts["Creating your video"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Saved to Photos"].waitForExistence(timeout: 10))
    }

    func testMockedHappyPathShowsResultAndFollowUp() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launch()

        completeOnboarding(app)
        app.buttons["Primary create"].tap()

        XCTAssertTrue(app.staticTexts["Edit"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Use sample video"].exists)
        XCTAssertFalse(app.staticTexts["Browse files"].exists)
        XCTAssertFalse(app.staticTexts["Choose from Photos"].exists)

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Make the mirror ripple like liquid.")
        app.buttons["Send"].tap()

        XCTAssertTrue(app.staticTexts["Saved to Mint"].waitForExistence(timeout: 10))

        app.textFields["Follow-up prompt"].tap()
        app.textFields["Follow-up prompt"].typeText("Make the arm reflective too.")
        app.buttons["Refine"].tap()

        XCTAssertTrue(app.staticTexts["Make the arm reflective too."].waitForExistence(timeout: 10))
    }

    private func completeOnboarding(_ app: XCUIApplication) {
        tapButton("Continue", in: app)
        XCTAssertTrue(app.staticTexts["Real example"].waitForExistence(timeout: 5))

        tapButton("Continue", in: app)
        XCTAssertTrue(app.staticTexts["Also: Generate"].waitForExistence(timeout: 5))

        tapButton("Get started", in: app)
        tapButton("Maybe later", in: app)
    }

    private func tapButton(_ label: String, in app: XCUIApplication, timeout: TimeInterval = 5) {
        let button = app.buttons[label]
        XCTAssertTrue(button.waitForExistence(timeout: timeout))
        let deadline = Date().addingTimeInterval(timeout)
        while button.isHittable == false, Date() < deadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        XCTAssertTrue(button.isHittable)
        button.tap()
    }
}
