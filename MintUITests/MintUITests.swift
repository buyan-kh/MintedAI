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

    func testMockedEditFlowStaysInEditorAndExportsLikeHTML() {
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
        XCTAssertFalse(app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] %@", "mint-sample")).firstMatch.exists)
        XCTAssertTrue(app.staticTexts["Ready"].exists)
        XCTAssertTrue(app.staticTexts["0 edits"].exists)
        XCTAssertTrue(app.staticTexts["8"].exists)
        XCTAssertTrue(app.staticTexts["/ 8"].exists)
        XCTAssertFalse(app.staticTexts["5"].exists)
        XCTAssertFalse(app.staticTexts["/ 5"].exists)
        XCTAssertTrue(app.buttons["🎬 Cinematic"].exists)
        XCTAssertTrue(app.buttons["🪞 Mirror ripple"].exists)
        XCTAssertTrue(app.buttons["✨ Reflective arm"].exists)
        XCTAssertTrue(app.buttons["⏱️ Slow motion"].exists)
        XCTAssertTrue(app.buttons["Edit video"].exists)
        XCTAssertTrue(app.buttons["Edit video"].isEnabled)

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Make the mirror ripple like liquid.")
        app.buttons["Edit video"].tap()

        XCTAssertFalse(app.staticTexts["Creating your video"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.staticTexts["Edit"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["v1"].exists)
        XCTAssertTrue(app.staticTexts["1 edits"].exists)
        let firstVersionButton = app.buttons["v1"]
        XCTAssertTrue(firstVersionButton.exists)
        XCTAssertTrue(app.buttons["Undo"].exists)
        XCTAssertTrue(app.buttons["Export video"].exists)
        XCTAssertFalse(app.staticTexts["Saved to Mint"].exists)
        XCTAssertFalse(app.textFields["Follow-up prompt"].exists)
        XCTAssertFalse(app.buttons["Refine"].exists)

        let versionDeadline = Date().addingTimeInterval(5)
        while firstVersionButton.isEnabled == false, Date() < versionDeadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        XCTAssertTrue(firstVersionButton.isEnabled)
        firstVersionButton.tap()
        XCTAssertTrue(app.staticTexts["Reverted to v1"].waitForExistence(timeout: 2))

        app.buttons["Undo"].tap()
        XCTAssertTrue(app.staticTexts["↩ Undid v1 — token restored"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["0 edits"].exists)
        XCTAssertTrue(app.staticTexts["8"].exists)
        XCTAssertTrue(app.staticTexts["/ 8"].exists)

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Make it glow softly.")
        app.buttons["Edit video"].tap()
        XCTAssertTrue(app.staticTexts["v1"].waitForExistence(timeout: 10))
        let exportButton = app.buttons["Export video"]
        let exportDeadline = Date().addingTimeInterval(8)
        while exportButton.isEnabled == false, Date() < exportDeadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        XCTAssertTrue(exportButton.isEnabled)
        exportButton.tap()

        XCTAssertTrue(app.staticTexts["Saved to Photos"].waitForExistence(timeout: 5))
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
        XCTAssertTrue(app.staticTexts["3 / 8"].exists)
        XCTAssertTrue(app.staticTexts["Token balance"].exists)
        XCTAssertTrue(app.staticTexts["2"].exists)
        XCTAssertTrue(app.staticTexts["Sign out"].exists)
        XCTAssertFalse(app.staticTexts["Videos created"].exists)
        XCTAssertFalse(app.staticTexts["Videos this month"].exists)
        XCTAssertFalse(app.staticTexts["Dark mode"].exists)
        XCTAssertFalse(app.staticTexts["Default export quality"].exists)
        XCTAssertTrue(app.staticTexts["Mint v1.0.2 · Build 42"].exists)
    }

    func testHomeRouteMatchesHTMLGalleryCopy() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launchEnvironment["MINT_START_ROUTE"] = "home"
        app.launch()

        XCTAssertTrue(app.staticTexts["Mint"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Your edits"].exists)
        XCTAssertTrue(app.staticTexts["Stateful AI edits live here."].exists)
        XCTAssertTrue(app.staticTexts["Views"].exists)
        XCTAssertFalse(app.staticTexts["Stateful AI edits live here. Start with a clip, then refine."].exists)
        XCTAssertFalse(app.staticTexts["Total views"].exists)
        XCTAssertTrue(app.buttons["Edit mode"].exists)
        XCTAssertTrue(app.buttons["Generate mode"].exists)
        XCTAssertTrue(app.buttons["All"].exists)
        XCTAssertTrue(app.buttons["Edited"].exists)
        XCTAssertTrue(app.buttons["Generated"].exists)
        XCTAssertTrue(app.buttons["Favorites"].exists)
        XCTAssertTrue(app.staticTexts["New edit"].exists)
        XCTAssertTrue(app.staticTexts["Mirror Ripple"].exists)
        XCTAssertTrue(app.staticTexts["Neon Tokyo"].exists)
        XCTAssertTrue(app.staticTexts["Beach Grade"].exists)
        XCTAssertTrue(app.staticTexts["Stargazing"].exists)
        XCTAssertTrue(app.staticTexts["Cherry Blossom"].exists)
        XCTAssertTrue(app.staticTexts["City Lights"].exists)
        XCTAssertTrue(app.staticTexts["Today"].exists)
        XCTAssertFalse(app.staticTexts["Mirror Ripple Edit"].exists)
        XCTAssertFalse(app.staticTexts["Neon Tokyo Cityscape"].exists)
        XCTAssertFalse(app.staticTexts["Beach Memories"].exists)
        XCTAssertFalse(app.staticTexts["Today · 234 views"].exists)
        XCTAssertFalse(app.staticTexts["✂️ 4 stateful edits"].exists)

        app.buttons["Generate mode"].tap()
        XCTAssertTrue(app.staticTexts["Generated"].exists)
        XCTAssertTrue(app.staticTexts["Stateful AI edits live here."].exists)
        XCTAssertFalse(app.staticTexts["Text-to-video. Describe a scene, AI creates it."].exists)
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
        XCTAssertTrue(app.staticTexts["8 edits/day included"].exists)
        XCTAssertTrue(app.staticTexts["Priority processing"].exists)
        XCTAssertTrue(app.staticTexts["Buy token packs for extra"].exists)
        XCTAssertTrue(app.buttons["Restore purchases"].exists)
        XCTAssertTrue(app.staticTexts["After trial: $14.99/month or $99.99/year. 8 edits/day included, extra token packs available. Cancel anytime."].exists)
        XCTAssertFalse(app.staticTexts["Lifetime"].exists)
        XCTAssertFalse(app.staticTexts["5 edits/day included"].exists)
        XCTAssertFalse(app.buttons["Start 7-day free trial"].exists)
    }

    func testGenerateRouteShowsHTMLTokenCounters() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launchEnvironment["MINT_START_ROUTE"] = "generate"
        app.launch()

        XCTAssertTrue(app.staticTexts["What do you want to see?"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["e.g. \"Cinematic slow-motion of a neon-lit cyberpunk city at night\""].exists)
        XCTAssertFalse(app.staticTexts["e.g. \"Cinematic slow-motion of a neon-lit cyberpunk city at night with rain and flying cars\""].exists)
        XCTAssertTrue(app.buttons["🌆 Cityscape"].exists)
        XCTAssertTrue(app.buttons["🌸 Anime"].exists)
        XCTAssertTrue(app.buttons["💻 Cyberpunk"].exists)
        XCTAssertEqual(app.staticTexts["Generate hero token count"].label, "8/8")
        XCTAssertEqual(app.staticTexts["Generate bottom token count"].label, "8/8")
    }

    func testGenerateOutOfTokensShowsBuyOverlay() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launchEnvironment["MINT_START_ROUTE"] = "generate"
        app.launchEnvironment["MINT_DAILY_TOKENS"] = "0"
        app.launchEnvironment["MINT_BANKED_TOKENS"] = "0"
        app.launch()

        XCTAssertTrue(app.staticTexts["What do you want to see?"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["Generate hero token count"].label, "0/8")

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("A polished launch video.")
        app.buttons["Generate"].tap()

        XCTAssertTrue(app.staticTexts["Out of daily edits"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["You've used all 8 today. Grab a pack to keep going."].exists)
        XCTAssertTrue(app.buttons["10 edits"].exists)
        XCTAssertTrue(app.buttons["50 edits"].exists)
        XCTAssertTrue(app.buttons["200 edits"].exists)
    }

    func testEditorBackConfirmsWhenEditsExist() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launch()

        completeOnboarding(app)
        app.buttons["Primary create"].tap()
        XCTAssertTrue(app.staticTexts["Edit"].waitForExistence(timeout: 5))

        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("Make the mirror ripple.")
        app.buttons["Edit video"].tap()
        XCTAssertTrue(app.staticTexts["v1"].waitForExistence(timeout: 10))

        app.buttons["← Back"].tap()
        XCTAssertTrue(app.alerts["You have unsaved edits. Leave anyway?"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Stay"].exists)
        XCTAssertTrue(app.buttons["Leave"].exists)
    }

    func testGeneratedVideoConsumesSharedTokenBeforeEditing() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_MOCK_GEMINI"]
        app.launchEnvironment["MINT_START_ROUTE"] = "generate"
        app.launch()

        XCTAssertTrue(app.staticTexts["What do you want to see?"].waitForExistence(timeout: 5))
        app.textViews.firstMatch.tap()
        app.textViews.firstMatch.typeText("A cinematic product reveal.")
        app.buttons["Generate"].tap()
        XCTAssertTrue(app.staticTexts["Saved to Photos"].waitForExistence(timeout: 10))

        app.buttons["Go to home"].tap()
        XCTAssertTrue(app.staticTexts["Mint"].waitForExistence(timeout: 5))
        app.buttons["Edit mode"].tap()
        app.buttons["Primary create"].tap()

        XCTAssertTrue(app.staticTexts["Edit"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["7"].exists)
        XCTAssertTrue(app.staticTexts["/ 8"].exists)
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
