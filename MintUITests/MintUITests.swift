import XCTest

@MainActor
final class MintUITests: XCTestCase {
    func testOnboardingFirstSlideMatchesHTMLHeroOnly() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Not another generator. Take any clip and transform it — prompt by prompt, like talking to your video."].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["✦ The AI editor, not generator"].exists)
        XCTAssertTrue(app.buttons["Continue"].exists)
        XCTAssertTrue(app.buttons["Skip"].exists)
        XCTAssertFalse(app.staticTexts["Pick a video, describe the change"].exists)
        XCTAssertFalse(app.staticTexts["Each edit builds on the last — stateful"].exists)
        XCTAssertFalse(app.staticTexts["Undo anything, keep what works"].exists)
    }

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
        XCTAssertTrue(app.staticTexts["Ready"].exists)
        XCTAssertTrue(app.staticTexts["0 edits"].exists)
        XCTAssertTrue(app.staticTexts["10"].exists)
        XCTAssertTrue(app.staticTexts["/ 10"].exists)
        XCTAssertTrue(app.buttons["🎬 Cinematic"].exists)
        XCTAssertTrue(app.buttons["🪞 Mirror ripple"].exists)
        XCTAssertTrue(app.buttons["✨ Reflective arm"].exists)
        XCTAssertTrue(app.buttons["⏱️ Slow motion"].exists)
        XCTAssertTrue(app.buttons["Edit video"].exists)

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Make the mirror ripple like liquid.")
        app.buttons["Edit video"].tap()

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
        XCTAssertTrue(app.staticTexts["Renews April 15, 2027 · $99.99/yr"].exists)
        XCTAssertTrue(app.staticTexts["Edits used today"].exists)
        XCTAssertTrue(app.staticTexts["3 / 5"].exists)
        XCTAssertTrue(app.staticTexts["Token balance"].exists)
        XCTAssertTrue(app.staticTexts["2"].exists)
        XCTAssertTrue(app.staticTexts["Sign out"].exists)
        XCTAssertFalse(app.staticTexts["Videos this month"].exists)
        XCTAssertFalse(app.staticTexts["Default export quality"].exists)
        XCTAssertTrue(app.staticTexts["Mint v1.0.2 · Build 42"].exists)
    }

    func testPaywallRouteMatchesHTMLPlansAndTrialCopy() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launchEnvironment["MINT_START_ROUTE"] = "paywall"
        app.launch()

        XCTAssertTrue(app.staticTexts["Unlock Mint Pro"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["🎁 3 days free"].exists)
        XCTAssertTrue(app.staticTexts["$8.33 / month"].exists)
        XCTAssertTrue(app.staticTexts["$99.99"].exists)
        XCTAssertTrue(app.staticTexts["$14.99 / month"].exists)
        XCTAssertTrue(app.buttons["Start 3-day free trial"].exists)
        XCTAssertTrue(app.staticTexts["5 edits/day included"].exists)
        XCTAssertTrue(app.staticTexts["Priority processing"].exists)
        XCTAssertTrue(app.staticTexts["Buy token packs for extra"].exists)
        XCTAssertFalse(app.staticTexts["Lifetime"].exists)
        XCTAssertFalse(app.buttons["Start 7-day free trial"].exists)
    }

    func testGenerateRouteShowsHTMLTokenCounters() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launchEnvironment["MINT_START_ROUTE"] = "generate"
        app.launch()

        XCTAssertTrue(app.staticTexts["What do you want to see?"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["Generate hero token count"].label, "5/5")
        XCTAssertEqual(app.staticTexts["Generate bottom token count"].label, "5/5")
    }

    func testProcessingRouteMatchesHTMLLoadingScreen() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launchEnvironment["MINT_START_ROUTE"] = "processing"
        app.launch()

        XCTAssertTrue(app.staticTexts["Creating your video"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["AI is working on it..."].exists)
        XCTAssertTrue(app.staticTexts["Starting..."].exists)
        XCTAssertTrue(app.descendants(matching: .any)["Processing progress track"].exists)
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
