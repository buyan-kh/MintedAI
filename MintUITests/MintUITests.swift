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
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", ".mp4")).firstMatch.exists)

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Make the mirror ripple like liquid.")
        app.buttons["Send"].tap()

        XCTAssertTrue(app.staticTexts["Saved to Mint"].waitForExistence(timeout: 10))

        app.textFields["Follow-up prompt"].tap()
        app.textFields["Follow-up prompt"].typeText("Make the arm reflective too.")
        app.buttons["Refine"].tap()

        XCTAssertTrue(app.staticTexts["Make the arm reflective too."].waitForExistence(timeout: 10))
    }

    func testSettingsGearOpensNativeSettingsScreen() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launchEnvironment["MINT_START_ROUTE"] = "home"
        app.launch()

        app.buttons["Settings"].tap()

        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Mint Pro Annual"].exists)
        XCTAssertTrue(app.staticTexts["Videos this month"].exists)
        XCTAssertTrue(app.staticTexts["Default export quality"].exists)
        XCTAssertTrue(app.staticTexts["Mint v1.0.2 · Build 42"].exists)
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
